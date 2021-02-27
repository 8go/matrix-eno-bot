#!/usr/bin/env python3

"""Echo back the command's arguments."""

import sys

if __name__ == "__main__":
    response = " ".join(sys.argv[1:])
    if response.strip() == "":
        response = "echo!"

    print(response)
    # await send_text_to_room(self.client, self.room.room_id, response)

