"""
シンプルな計算機サンプル - Claude Code Actions 動作検証用
"""


def add(a: float, b: float) -> float:
    return a + b


def subtract(a: float, b: float) -> float:
    return a - b


def multiply(a: float, b: float) -> float:
    return a * b


def divide(a: float, b: float) -> float:
    if b == 0:
        raise ValueError("ゼロ除算はできません")
    return a / b


if __name__ == "__main__":
    print(f"10 + 3 = {add(10, 3)}")
    print(f"10 - 3 = {subtract(10, 3)}")
    print(f"10 * 3 = {multiply(10, 3)}")
    print(f"10 / 3 = {divide(10, 3):.4f}")
