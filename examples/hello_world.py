"""
動作検証用サンプルスクリプト
Claude Code Actions 経由でのファイル作成・PR作成フローの検証用
"""


def greet(name: str = "World") -> str:
    """挨拶メッセージを返す"""
    return f"Hello, {name}!"


def main():
    print(greet())
    print(greet("Claude Code Actions"))


if __name__ == "__main__":
    main()
