import XCTest
@testable import BookNest

final class SignUpViewModelTests: XCTestCase {
    var viewModel: SignUpViewModel!
    
    override func setUp() async throws {
        try await super.setUp()
        viewModel = await SignUpViewModel()
    }
    
    override func tearDown() async throws {
        viewModel = nil
        try await super.tearDown()
    }
    
    func testValidateForm_withEmptyFields_shouldReturnInvalid() async {
        let validationResult = await viewModel.validateForm()
        XCTAssertFalse(validationResult.isValid, "Validation should fail if fields are empty.")
        XCTAssertEqual(validationResult.message, "All fields are required.", "Validation message mismatch.")
    }
    
    func testValidateForm_withInvalidEmail_shouldReturnInvalid() async {
        await MainActor.run {
            viewModel.fullName = "Test User"
            viewModel.userName = "testuser"
            viewModel.email = "invalidemail"
            viewModel.password = "password123"
            viewModel.confirmPassword = "password123"
        }
        
        let validationResult = await viewModel.validateForm()
        XCTAssertFalse(validationResult.isValid, "Validation should fail with invalid email format.")
        XCTAssertEqual(validationResult.message, "Please enter a valid email address.", "Validation message mismatch.")
    }
    
    func testValidateForm_withShortPassword_shouldReturnInvalid() async {
        await MainActor.run {
            viewModel.fullName = "Test User"
            viewModel.userName = "testuser"
            viewModel.email = "test@example.com"
            viewModel.password = "pass"
            viewModel.confirmPassword = "pass"
        }
        
        let validationResult = await viewModel.validateForm()
        XCTAssertFalse(validationResult.isValid, "Validation should fail with password shorter than 6 characters.")
        XCTAssertEqual(validationResult.message, "Password must be at least 6 characters long.", "Validation message mismatch.")
    }
    
    func testValidateForm_withMismatchedPasswords_shouldReturnInvalid() async {
        await MainActor.run {
            viewModel.fullName = "Test User"
            viewModel.userName = "testuser"
            viewModel.email = "test@example.com"
            viewModel.password = "password123"
            viewModel.confirmPassword = "password321"
        }
        
        let validationResult = await viewModel.validateForm()
        XCTAssertFalse(validationResult.isValid, "Validation should fail if passwords do not match.")
        XCTAssertEqual(validationResult.message, "Passwords do not match.", "Validation message mismatch.")
    }
    
    func testValidateForm_withValidData_shouldReturnValid() async {
        await MainActor.run {
            viewModel.fullName = "Test User"
            viewModel.userName = "testuser"
            viewModel.email = "test@example.com"
            viewModel.password = "password123"
            viewModel.confirmPassword = "password123"
        }
        
        let validationResult = await viewModel.validateForm()
        XCTAssertTrue(validationResult.isValid, "Validation should succeed with valid data.")
        XCTAssertNil(validationResult.message, "Validation message should be nil for valid data.")
    }
    
    func testIsValidEmail() async {
        let validEmail = await viewModel.isValidEmail("test@example.com")
        let invalidEmail = await viewModel.isValidEmail("invalid-email")
        
        XCTAssertTrue(validEmail, "Email validation should succeed for a valid email.")
        XCTAssertFalse(invalidEmail, "Email validation should fail for an invalid email.")
    }
    
    func testSignUp_withInvalidData_shouldFail() async {
        await MainActor.run {
            viewModel.fullName = "Test User"
            viewModel.userName = "testuser"
            viewModel.email = "test@example.com"
            viewModel.password = "password123"
            viewModel.confirmPassword = "password123"
        }
        
        await viewModel.SignUp()
        
        await MainActor.run {
            XCTAssertTrue(viewModel.isSuccess, "Sign-up should succeed with valid data.")
            XCTAssertEqual(viewModel.statusMessage, "Sign-up successful!", "Success message mismatch.")
        }
    }
}
