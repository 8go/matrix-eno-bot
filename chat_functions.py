#!/usr/bin/env python3

r"""chat_functions.py.

0123456789012345678901234567890123456789012345678901234567890123456789012345678
0000000000111111111122222222223333333333444444444455555555556666666666777777777

# chat_functions.py

This file implements utility functions for
- sending text messages
- sending images
- sending of other files like audio, video, text, PDFs, .doc, etc.

Don't change tabbing, spacing, or formating as the
file is automatically linted and beautified.

"""

import logging
import os
import traceback

import aiofiles.os
import magic
from markdown import markdown
from nio import SendRetryError, UploadResponse
from PIL import Image

logger = logging.getLogger(__name__)


async def send_text_to_room(
    client,
    room_id,
    message,
    notice=True,
    markdown_convert=True,
    formatted=True,
    code=False,
    split=None,
):
    """Send text to a matrix room.

    Arguments:
    ---------
    client (nio.AsyncClient): The client to communicate with Matrix

    room_id (str): The ID of the room to send the message to

    message (str): The message content

    notice (bool): Whether the message should be sent with an
        "m.notice" message type (will not ping users)

    markdown_convert (bool): Whether to convert the message content
        to markdown. Defaults to true.

    formatted (bool): whether message should be sent as formatted message.
        Defaults to True.

    code (bool): whether message should be sent as code block with
        fixed-size font.
        If set to True, markdown_convert will be ignored.
        Defaults to False

    split (str): if set, split the message into multiple messages wherever
        the string specified in split occurs
        Defaults to None

    """
    logger.debug(f"send_text_to_room {room_id} {message}")
    messages = []
    if split:
        for paragraph in message.split(split):
            # strip again to get get rid of leading/trailing newlines and
            # whitespaces left over from previous split
            if paragraph.strip() != "":
                messages.append(paragraph)
    else:
        messages.append(message)

    for message in messages:
        # Determine whether to ping room members or not
        msgtype = "m.notice" if notice else "m.text"

        content = {
            "msgtype": msgtype,
            "body": message,
        }

        if formatted:
            content["format"] = "org.matrix.custom.html"

        if code:
            content["formatted_body"] = "<pre><code>" + message + "\n</code></pre>\n"
            # next line: work-around for Element on Android
            content["body"] = "```\n" + message + "\n```"  # to format it as code
        elif markdown_convert:
            content["formatted_body"] = markdown(message)

        try:
            await client.room_send(
                room_id, "m.room.message", content, ignore_unverified_devices=True,
            )
        except SendRetryError:
            logger.exception(f"Unable to send message response to {room_id}")


async def send_image_to_room(client, room_id, image):
    """Send image to single room.

    Arguments:
    ---------
    client (nio.AsyncClient): The client to communicate with Matrix
    room_id (str): The ID of the room to send the message to
    image (str): file name/path of image

    """
    logger.debug(f"send_image_to_room {room_id} {image}")
    await send_image_to_rooms(client, [room_id], image)


async def send_image_to_rooms(client, rooms, image):
    """Send image to multiple rooms.

    Arguments:
    ---------
    client (nio.AsyncClient): The client to communicate with Matrix
    rooms (list): list of room_id-s
    image (str): file name/path of image

    This is a working example for a JPG image.
        "content": {
            "body": "someimage.jpg",
            "info": {
                "size": 5420,
                "mimetype": "image/jpeg",
                "thumbnail_info": {
                    "w": 100,
                    "h": 100,
                    "mimetype": "image/jpeg",
                    "size": 2106
                },
                "w": 100,
                "h": 100,
                "thumbnail_url": "mxc://example.com/SomeStrangeThumbnailUriKey"
            },
            "msgtype": "m.image",
            "url": "mxc://example.com/SomeStrangeUriKey"
        }

    """
    if not rooms:
        logger.info(
            "No rooms are given. This should not happen. "
            "This file is being droppend and NOT sent."
        )
        return
    if not os.path.isfile(image):
        logger.debug(
            f"File {image} is not a file. Doesn't exist or "
            "is a directory."
            "This file is being droppend and NOT sent."
        )
        return

    mime_type = magic.from_file(image, mime=True)  # e.g. "image/jpeg"
    if not mime_type.startswith("image/"):
        logger.debug("Drop message because file does not have an image mime type.")
        return

    im = Image.open(image)
    (width, height) = im.size  # im.size returns (width,height) tuple

    # first do an upload of image, then send URI of upload to room
    file_stat = await aiofiles.os.stat(image)
    async with aiofiles.open(image, "r+b") as f:
        resp, maybe_keys = await client.upload(
            f,
            content_type=mime_type,  # image/jpeg
            filename=os.path.basename(image),
            filesize=file_stat.st_size,
        )
    if isinstance(resp, UploadResponse):
        logger.debug("Image was uploaded successfully to server. ")
    else:
        logger.debug(f"Failed to upload image. Failure response: {resp}")

    content = {
        "body": os.path.basename(image),  # descriptive title
        "info": {
            "size": file_stat.st_size,
            "mimetype": mime_type,
            "thumbnail_info": None,  # TODO
            "w": width,  # width in pixel
            "h": height,  # height in pixel
            "thumbnail_url": None,  # TODO
        },
        "msgtype": "m.image",
        "url": resp.content_uri,
    }

    try:
        for room_id in rooms:
            await client.room_send(
                room_id, message_type="m.room.message", content=content
            )
            logger.debug(f'This image was sent: "{image}" to room "{room_id}".')
    except Exception:
        logger.debug(
            f"Image send of file {image} failed. " "Sorry. Here is the traceback."
        )
        logger.debug(traceback.format_exc())


async def send_file_to_room(client, room_id, file):
    """Send file to single room.

    Arguments:
    ---------
    client (nio.AsyncClient): The client to communicate with Matrix
    room_id (str): The ID of the room to send the file to
    file (str): file name/path of file

    """
    logger.debug(f"send_file_to_room {room_id} {file}")
    await send_file_to_rooms(client, [room_id], file)


async def send_file_to_rooms(client, rooms, file):
    """Send file to multiple rooms.

    Upload file to server and then send link to rooms.
    Works and tested for .pdf, .txt, .ogg, .wav.
    All these file types are treated the same.

    Do not use this function for images.
    Use the send_image_to_room() function for images.

    Matrix has types for audio and video (and image and file).
    See: "msgtype" == "m.image", m.audio, m.video, m.file

    Arguments:
    ---------
    client (nio.AsyncClient): The client to communicate with Matrix
    room_id (str): The ID of the room to send the file to
    rooms (list): list of room_id-s
    file (str): file name/path of file

    This is a working example for a PDF file.
    It can be viewed or downloaded from:
    https://matrix.example.com/_matrix/media/r0/download/
        example.com/SomeStrangeUriKey # noqa
    {
        "type": "m.room.message",
        "sender": "@someuser:example.com",
        "content": {
            "body": "example.pdf",
            "info": {
                "size": 6301234,
                "mimetype": "application/pdf"
                },
            "msgtype": "m.file",
            "url": "mxc://example.com/SomeStrangeUriKey"
        },
        "origin_server_ts": 1595100000000,
        "unsigned": {
            "age": 1000,
            "transaction_id": "SomeTxId01234567"
        },
        "event_id": "$SomeEventId01234567789Abcdef012345678",
        "room_id": "!SomeRoomId:example.com"
    }

    """
    if not rooms:
        logger.info(
            "No rooms are given. This should not happen. "
            "This file is being droppend and NOT sent."
        )
        return
    if not os.path.isfile(file):
        logger.debug(
            f"File {file} is not a file. Doesn't exist or "
            "is a directory."
            "This file is being droppend and NOT sent."
        )
        return

    # # restrict to "txt", "pdf", "mp3", "ogg", "wav", ...
    # if not re.match("^.pdf$|^.txt$|^.doc$|^.xls$|^.mobi$|^.mp3$",
    #                os.path.splitext(file)[1].lower()):
    #    logger.debug(f"File {file} is not a permitted file type. Should be "
    #                 ".pdf, .txt, .doc, .xls, .mobi or .mp3 ... "
    #                 f"[{os.path.splitext(file)[1].lower()}]"
    #                 "This file is being droppend and NOT sent.")
    #    return

    # 'application/pdf' "plain/text" "audio/ogg"
    mime_type = magic.from_file(file, mime=True)
    # if ((not mime_type.startswith("application/")) and
    #        (not mime_type.startswith("plain/")) and
    #        (not mime_type.startswith("audio/"))):
    #    logger.debug(f"File {file} does not have an accepted mime type. "
    #                 "Should be something like application/pdf. "
    #                 f"Found mime type {mime_type}. "
    #                 "This file is being droppend and NOT sent.")
    #    return

    # first do an upload of file, see upload() in documentation
    # http://matrix-nio.readthedocs.io/en/latest/nio.html#nio.AsyncClient.upload
    # then send URI of upload to room

    file_stat = await aiofiles.os.stat(file)
    async with aiofiles.open(file, "r+b") as f:
        resp, maybe_keys = await client.upload(
            f,
            content_type=mime_type,  # application/pdf
            filename=os.path.basename(file),
            filesize=file_stat.st_size,
        )
    if isinstance(resp, UploadResponse):
        logger.debug(f"File was uploaded successfully to server. Response is: {resp}")
    else:
        logger.info(
            "Bot failed to upload. "
            "Please retry. This could be temporary issue on your server. "
            "Sorry."
        )
        logger.info(
            f'file="{file}"; mime_type="{mime_type}"; '
            f'filessize="{file_stat.st_size}"'
            f"Failed to upload: {resp}"
        )

    # determine msg_type:
    if mime_type.startswith("audio/"):
        msg_type = "m.audio"
    elif mime_type.startswith("video/"):
        msg_type = "m.video"
    else:
        msg_type = "m.file"

    content = {
        "body": os.path.basename(file),  # descriptive title
        "info": {"size": file_stat.st_size, "mimetype": mime_type,},  # noqa
        "msgtype": msg_type,
        "url": resp.content_uri,
    }

    try:
        for room_id in rooms:
            await client.room_send(
                room_id, message_type="m.room.message", content=content
            )
            logger.debug(f'This file was sent: "{file}" to room "{room_id}".')
    except Exception:
        logger.debug(f"File send of file {file} failed. Sorry. Here is the traceback.")
        logger.debug(traceback.format_exc())
