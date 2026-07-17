"""add read_at to messages

Revision ID: a3d8f0b2c9e1
Revises: 970e7d2cb57e
Create Date: 2026-07-17 00:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = "a3d8f0b2c9e1"
down_revision: Union[str, Sequence[str], None] = "970e7d2cb57e"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column("messages", sa.Column("read_at", sa.DateTime(timezone=True), nullable=True))


def downgrade() -> None:
    op.drop_column("messages", "read_at")
