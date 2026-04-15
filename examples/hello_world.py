"""
Claude Code Actions 動作検証用サンプルスクリプト
"""


def greet(name: str = "World") -> str:
    """挨拶メッセージを返す"""
    return f"Hello, {name}!"


def main():
    print(greet())
    print(greet("Claude Code Actions"))


if __name__ == "__main__":
    main()
