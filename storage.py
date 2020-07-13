import sqlite3
import os.path
import logging

latest_db_version = 0

logger = logging.getLogger(__name__)


class Storage(object):
    def __init__(self, db_path):
        """Setup the database

        Runs an initial setup or migrations depending on whether a database file has already
        been created

        Args:
            db_path (str): The name of the database file
        """
        self.db_path = db_path

        # Check if a database has already been connected
        if os.path.isfile(self.db_path):
            self._run_migrations()
        else:
            self._initial_setup()

    def _initial_setup(self):
        """Initial setup of the database"""
        logger.info("Performing initial database setup...")

        # Initialize a connection to the database
        self.conn = sqlite3.connect(self.db_path)
        self.cursor = self.conn.cursor()

        # Sync token table
        self.cursor.execute("CREATE TABLE sync_token ("
                            "dedupe_id INTEGER PRIMARY KEY, "
                            "token TEXT NOT NULL"
                            ")")

        logger.info("Database setup complete")

    def _run_migrations(self):
        """Execute database migrations"""
        # Initialize a connection to the database
        self.conn = sqlite3.connect(self.db_path)
        self.cursor = self.conn.cursor()
