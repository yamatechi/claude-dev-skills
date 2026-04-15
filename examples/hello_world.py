"""
Claude Code Actions 経由での動作検証用サンプルスクリプト。
"""


def greet(name: str = "World") -> str:
    """指定した名前への挨拶メッセージを返す。"""
    return f"Hello, {name}!"


def main() -> None:
    print(greet())
    print(greet("Claude Code Actions"))


if __name__ == "__main__":
    main()
