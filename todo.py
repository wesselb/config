"""A simple script to organise TODOs in a Markdown file."""

import datetime
import re
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Union

now = datetime.datetime.now().strftime("%Y-%m-%d %H:%M")
indent = 4


@dataclass
class TODO:
    level: int
    parent: Union["TODO", None]
    lines: list[str]
    todos: list["TODO"]

    @property
    def text(self) -> str:
        return "\n".join(self.lines) + "\n"


@dataclass
class Section:
    level: int
    parent: Union["Section", None]
    lines: list[str]
    todos: list[TODO]
    sections: list["Section"]


def is_todo(line: str) -> bool:
    """Check whether a line starts a TODO."""
    line = line.lstrip()
    return line.startswith("-") or line.startswith("*")


def is_section(line: str) -> bool:
    """Check whether a line starts a section."""
    return line.startswith("#")


def section_name(section: Section) -> str:
    """Get the name of the section."""
    if not section.lines:
        return ""
    line = section.lines[0]
    start = 0
    while start < len(line) and line[start] == "#":
        start += 1
    return line[start:].strip()


def is_archive(section: Section) -> bool:
    """Check whether a section is an archive.

    A section is an archive if it lives on the top level and is named "archive", which
    is not case sensitive.
    """
    if section.level != 1:
        return False
    return section_name(section).lower() == "archive"


def pretty_print(x: Section | TODO) -> None:
    """Pretty print a section or TODO."""
    for line in x.lines:
        print(line)
    for todo in x.todos:
        pretty_print(todo)
    if isinstance(x, Section):
        for section in x.sections:
            pretty_print(section)


def find_todo_level_parent(
    line: str,
    supertodo: TODO | None,
) -> tuple[int, TODO | None]:
    """Find the level and parent of a new TODO."""
    level = 0
    while line[level] == " ":
        level += 1

    parent: TODO | None = supertodo
    while parent and parent.level >= level:
        parent = parent.parent

    return level, parent


def find_section_level_parent(line: str, supersection: Section) -> tuple[int, Section]:
    """Find the level and parent of a new section."""
    level = 0
    while line[level] == "#":
        level += 1

    parent: Section | None = supersection
    while parent and parent.level >= level:
        parent = parent.parent
    assert parent

    return level, parent


def process_section(section: Section, path: str, to_archive: list[TODO]) -> None:
    """Process a section, performing all actions."""
    if is_archive(section):
        return

    if path:
        path += " / "
    path += section_name(section)

    mask: list[bool] = []
    for todo in section.todos:
        mask.append(process_todo(todo, path, to_archive))
    # Perform archival according to mask:
    section.todos = [t for m, t in zip(mask, section.todos) if m]

    for section in section.sections:
        process_section(section, path, to_archive)


def contains_tag(todo: TODO, name: str) -> bool:
    """Check whether a TODO contains a tag."""
    return f"@{name}" in todo.text


def activate_tag(todo: TODO, name: str, value: str) -> None:
    """Activate a tag."""
    for i, line in enumerate(todo.lines):
        line = re.sub(f"@{re.escape(name)} ", f"@{name}({value}) ", line)
        line = re.sub(f"@{re.escape(name)}$", f"@{name}({value})", line)
        todo.lines[i] = line


def add_tag(todo: TODO, name: str, value: str) -> None:
    """Add a tag."""
    todo.lines.insert(1, " " * (todo.level + indent) + f"@{name}({value})")


def dedent(todo: TODO) -> None:
    """Dedent a TODO and bring it to the top level."""
    indent = " " * todo.level
    for i, line in enumerate(todo.lines):
        line = line.removeprefix(indent)
        todo.lines[i] = line
    todo.level = 0
    todo.parent = None


def process_todo(todo: TODO, path: str, to_archive: list[TODO]) -> bool:
    """Process a TODO, performing all actions.

    Returns whether or not to retain the TODO.
    """
    retain = True

    if "[/]" in todo.lines[0] and not contains_tag(todo, "started"):
        add_tag(todo, "started", now)

    if "[x]" in todo.lines[0] and not contains_tag(todo, "completed"):
        add_tag(todo, "completed", now)

    if contains_tag(todo, "archived"):
        if path:
            add_tag(todo, "path", path)
        activate_tag(todo, "archived", now)
        dedent(todo)
        to_archive.append(todo)
        retain = False

    mask: list[bool] = []
    for subtodo in todo.todos:
        mask.append(process_todo(subtodo, path, to_archive))
    # Perform archival according to mask:
    todo.todos = [t for m, t in zip(mask, todo.todos) if m]

    return retain


def main(path: Path) -> None:
    section = Section(0, None, [], [], [])
    todo: TODO | None = None
    document = section
    archive: Section | None = None

    with path.open("r") as f:
        lines = [line.rstrip() for line in f.readlines()]

        while lines:
            line = lines.pop(0)

            # Process a new TODO.
            if is_todo(line):
                todo = TODO(*find_todo_level_parent(line, todo), [line], [])
                if todo.parent:
                    todo.parent.todos.append(todo)
                else:
                    section.todos.append(todo)

                while lines and not is_section(lines[0]) and not is_todo(lines[0]):
                    todo.lines.append(lines.pop(0))

            # Process a new section.
            elif is_section(line):
                level, parent = find_section_level_parent(line, section)
                section = Section(level, parent, [line], [], [])
                parent.sections.append(section)
                todo = None

                if is_archive(section):
                    if archive:
                        print("ERROR: Found two top-level archive sections.")
                        exit(3)
                    archive = section

            else:
                section.lines.append(line)
                todo = None

    if not archive:
        print("ERROR: Top-level archive section not found.")
        exit(4)

    to_archive: list[TODO] = []
    process_section(document, "", to_archive)
    for todo in to_archive:
        archive.todos.append(todo)

    pretty_print(document)


if __name__ == "__main__":
    args = sys.argv[1:]

    if len(args) != 1:
        print("ERROR: Must give exactly one argument.")
        exit(1)

    path = Path(args[0]).expanduser().resolve()

    if not path.exists() or not path.is_file():
        print("ERROR: Argument must point to an existing file.")
        exit(2)

    main(path)
