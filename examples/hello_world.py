"""
Claude Code Actions 経由での動作検証用スクリプト。
"""


def greet(name: str = "World") -> str:
    """挨拶メッセージを返す。"""
    return f"Hello, {name}!"


if __name__ == "__main__":
    message = greet("Claude Code Actions")
    print(message)
