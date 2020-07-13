import logging
from nio import (
    SendRetryError
)
from markdown import markdown

logger = logging.getLogger(__name__)


async def send_text_to_room(
    client,
    room_id,
    message,
    notice=True,
    markdown_convert=True,
    formatted=True,
    code=False
):
    """Send text to a matrix room

    Args:
        client (nio.AsyncClient): The client to communicate to matrix with

        room_id (str): The ID of the room to send the message to

        message (str): The message content

        notice (bool): Whether the message should be sent with an "m.notice" message type
            (will not ping users)

        markdown_convert (bool): Whether to convert the message content to markdown.
            Defaults to true.

        formatted (bool): whether message should be sent as formatted message.
            Defaults to True.

        code (bool): wether message should be sent as code block with fixed-size font
            If set to True, markdown_convert will be ignored.
            Defaults to False
    """
    # Determine whether to ping room members or not
    msgtype = "m.notice" if notice else "m.text"

    content = {
        "msgtype": msgtype,
        "body": message,
    }

    if formatted:
        content["format"] = "org.matrix.custom.html"

    if code:
        content["formatted_body"] = "<pre><code>" + message + "</code></pre>"
    elif markdown_convert:
        content["formatted_body"] = markdown(message)

    try:
        await client.room_send(
            room_id,
            "m.room.message",
            content,
            ignore_unverified_devices=True,
        )
    except SendRetryError:
        logger.exception(f"Unable to send message response to {room_id}")

