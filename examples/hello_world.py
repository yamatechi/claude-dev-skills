"""
動作検証用のサンプルスクリプト。

Claude Code Actions 経由でのファイル作成・PR作成フローの検証に使用。
"""


def greet(name: str) -> str:
    """名前を受け取って挨拶メッセージを返す。"""
    return f"こんにちは、{name}！Claude Code Actions が正常に動作しています。"


def main() -> None:
    message = greet("World")
    print(message)


if __name__ == "__main__":
    main()
