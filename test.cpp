// Modern C++20 and C++23 Feature Demonstrations
// Compiled with C++23 standard (ISO/IEC 14882:2024)

#include <catch2/catch_test_macros.hpp>

#include <algorithm>
#include <compare>
#include <concepts>
#include <cstdint>
#include <expected>
#include <print>
#include <ranges>
#include <vector>
#include <string>
#include <string_view>

// ============================================================================
// C++20 Feature: Concepts
// Define constraints on template parameters for type safety
// ============================================================================

template<typename T>
concept Numeric = std::integral<T> || std::floating_point<T>;

template<Numeric T>
auto factorial(T number) -> T {
    return number <= 1 ? number : factorial(number - 1) * number;
}

// ============================================================================
// C++20 Feature: Three-way Comparison (Spaceship Operator)
// Automatically generates all comparison operators
// ============================================================================

struct Version {
    int major;
    int minor;
    int patch;

    // Compiler generates all six comparison operators from this
    auto operator<=>(const Version&) const = default;
};

// ============================================================================
// C++23 Feature: Deducing this (Explicit Object Parameter)
// Allows CRTP-like patterns without inheritance
// ============================================================================

struct Counter {
    int value = 0;

    // C++23: explicit object parameter lets us deduce the type
    template<typename Self>
    auto increment(this Self&& self) -> Self&& {
        ++self.value;
        return std::forward<Self>(self);
    }

    template<typename Self>
    auto get(this Self&& self) {
        return self.value;
    }
};

// ============================================================================
// C++23 Feature: std::expected for error handling
// Type-safe error handling without exceptions
// ============================================================================

enum class MathError {
    DivisionByZero,
    NegativeSquareRoot
};

auto safe_divide(double a, double b) -> std::expected<double, MathError> {
    if (b == 0.0) {
        return std::unexpected(MathError::DivisionByZero);
    }
    return a / b;
}

// ============================================================================
// C++20 Feature: Ranges
// Composable operations on sequences
// ============================================================================

auto filter_and_transform(const std::vector<int>& numbers) -> std::vector<int> {
    auto result = numbers
        | std::views::filter([](int n) { return n % 2 == 0; })
        | std::views::transform([](int n) { return n * n; })
        | std::ranges::to<std::vector>();
    return result;
}

// ============================================================================
// Tests
// ============================================================================

TEST_CASE("C++20 Concepts: Factorial with type constraints", "[cpp20][concepts]") {
    // Integer types
    REQUIRE(factorial(5) == 120);
    REQUIRE(factorial(10U) == 3'628'800);

    // Floating point types
    REQUIRE(factorial(5.0) == 120.0);

    // The following would not compile (concepts enforce constraints):
    // factorial("test");  // Error: string is not Numeric
}

TEST_CASE("C++20 Spaceship operator: Three-way comparison", "[cpp20][spaceship]") {
    Version v1{1, 2, 3};
    Version v2{1, 2, 3};
    Version v3{2, 0, 0};

    // All comparison operators work from a single <=> definition
    REQUIRE(v1 == v2);
    REQUIRE(v1 != v3);
    REQUIRE(v1 < v3);
    REQUIRE(v3 > v1);
    REQUIRE(v1 <= v2);
    REQUIRE(v1 >= v2);
}

TEST_CASE("C++23 Deducing this: Explicit object parameters", "[cpp23][deducing-this]") {
    Counter c;

    // Method chaining works naturally with deducing this
    c.increment().increment().increment();

    REQUIRE(c.get() == 3);
}

TEST_CASE("C++23 std::expected: Type-safe error handling", "[cpp23][expected]") {
    auto result1 = safe_divide(10.0, 2.0);
    REQUIRE(result1.has_value());
    REQUIRE(result1.value() == 5.0);

    auto result2 = safe_divide(10.0, 0.0);
    REQUIRE(!result2.has_value());
    REQUIRE(result2.error() == MathError::DivisionByZero);

    // Monadic operations (C++23)
    auto chained = safe_divide(100.0, 10.0)
        .and_then([](double x) { return safe_divide(x, 2.0); });
    REQUIRE(chained.value() == 5.0);
}

TEST_CASE("C++20 Ranges: Composable sequence operations", "[cpp20][ranges]") {
    std::vector<int> numbers{1, 2, 3, 4, 5, 6, 7, 8, 9, 10};

    // Filter evens and square them: {4, 16, 36, 64, 100}
    auto result = filter_and_transform(numbers);

    REQUIRE(result.size() == 5);
    REQUIRE(result[0] == 4);
    REQUIRE(result[1] == 16);
    REQUIRE(result[2] == 36);
    REQUIRE(result[3] == 64);
    REQUIRE(result[4] == 100);
}

TEST_CASE("C++23 std::print: Modern formatted output", "[cpp23][print]") {
    // std::print provides type-safe, format-string based output
    // This test verifies the API is available (output goes to stdout)
    std::println("Testing C++23 features with GCC 15.2 / Clang 21.1.5");
    std::println("CMake version: 4.1.2+");
    std::println("C++ Standard: C++23 (ISO/IEC 14882:2024)");

    // Format with arguments
    std::println("Factorial of {} is {}", 5, factorial(5));

    REQUIRE(true); // Test passes if std::println compiles and runs
}

TEST_CASE("C++20 Digit separators and binary literals", "[cpp20][literals]") {
    // Binary literals (C++14) with digit separators (C++14)
    auto million = 1'000'000;
    auto binary = 0b1010'1010;
    auto hex = 0xDE'AD'BE'EF;

    REQUIRE(million == 1000000);
    REQUIRE(binary == 170);
    REQUIRE(hex == 3'735'928'559);
}
