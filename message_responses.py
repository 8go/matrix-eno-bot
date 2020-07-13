from chat_functions import send_text_to_room
import logging

logger = logging.getLogger(__name__)


class Message(object):

    def __init__(self, client, store, config, message_content, room, event):
        """Initialize a new Message

        Args:
            client (nio.AsyncClient): nio client used to interact with matrix

            store (Storage): Bot storage

            config (Config): Bot configuration parameters

            message_content (str): The body of the message

            room (nio.rooms.MatrixRoom): The room the event came from

            event (nio.events.room_events.RoomMessageText): The event defining the message
        """
        self.client = client
        self.store = store
        self.config = config
        self.message_content = message_content
        self.room = room
        self.event = event

    async def process(self):
        """Process and possibly respond to the message"""
        if self.message_content.lower() == "hello world":
            await self._hello_world()

    async def _hello_world(self):
        """Say hello"""
        text = "Hello, world!"
        await send_text_to_room(self.client, self.room.room_id, text)

