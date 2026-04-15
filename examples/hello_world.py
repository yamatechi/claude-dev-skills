"""
Claude Code Actions 動作検証用サンプルスクリプト

このファイルは Claude Code Actions 経由でのファイル作成・PR作成フローの
動作検証を目的として作成されました。
"""


def greet(name: str = "World") -> str:
    """挨拶メッセージを返す関数。

    Args:
        name: 挨拶する相手の名前（デフォルト: "World"）

    Returns:
        挨拶メッセージの文字列
    """
    return f"Hello, {name}!"


def main() -> None:
    """メイン処理。"""
    print(greet())
    print(greet("Claude Code Actions"))


if __name__ == "__main__":
    main()
