"""
Credit Scoring API - Demo CLI
Demonstrates the new 2-step loan application flow
"""
import requests
import json
from typing import Dict, Any
import os
import sys

# Try to use colorama for Windows compatibility
try:
    from colorama import init, Fore, Back, Style
    init(autoreset=True)
    USE_COLORAMA = True
except ImportError:
    USE_COLORAMA = False
    print("Note: Install colorama for colored output: pip install colorama")

# API endpoints - Using cloud-hosted API
API_BASE = "https://credit-scoring-h7mv.onrender.com/api"
CALCULATE_LIMIT_URL = f"{API_BASE}/calculate-limit"
CALCULATE_TERMS_URL = f"{API_BASE}/calculate-terms"

# Color codes
class Colors:
    if USE_COLORAMA:
        HEADER = Fore.MAGENTA + Style.BRIGHT
        OKBLUE = Fore.BLUE + Style.BRIGHT
        OKCYAN = Fore.CYAN
        OKGREEN = Fore.GREEN + Style.BRIGHT
        WARNING = Fore.YELLOW
        FAIL = Fore.RED + Style.BRIGHT
        ENDC = Style.RESET_ALL
        BOLD = Style.BRIGHT
    else:
        HEADER = OKBLUE = OKCYAN = OKGREEN = WARNING = FAIL = ENDC = BOLD = ''

def clear_screen():
    """Clear terminal screen"""
    os.system('cls' if os.name == 'nt' else 'clear')

def print_header():
    """Print demo header"""
    clear_screen()
    print(f"{Colors.HEADER}{Colors.BOLD}")
    print("=" * 70)
    print("    CREDIT SCORING API - 2-STEP LOAN APPLICATION DEMO")
    print("=" * 70)
    print(f"{Colors.ENDC}\n")

def format_currency(amount: float) -> str:
    """Format amount in VND"""
    if amount >= 1_000_000_000:
        return f"{amount/1_000_000_000:.2f} ty VND"
    elif amount >= 1_000_000:
        return f"{amount/1_000_000:.0f} trieu VND"
    else:
        return f"{amount:,.0f} VND"

def get_customer_input() -> Dict[str, Any]:
    """Get customer information from user"""
    print(f"{Colors.OKBLUE}Enter Customer Information:{Colors.ENDC}\n")
    
    full_name = input("Full Name: ").strip() or "Nguyen Van A"
    age = int(input("Age (18-100): ").strip() or "30")
    monthly_income = float(input("Monthly Income (VND, e.g., 20000000): ").strip() or "20000000")
    
    print("\nEmployment Status:")
    print("  1. EMPLOYED")
    print("  2. SELF_EMPLOYED")
    print("  3. UNEMPLOYED")
    emp_choice = input("Select (1-3): ").strip() or "1"
    employment_status = ["EMPLOYED", "SELF_EMPLOYED", "UNEMPLOYED"][int(emp_choice) - 1]
    
    years_employed = float(input("Years Employed: ").strip() or "5.0")
    
    print("\nHome Ownership:")
    print("  1. RENT")
    print("  2. OWN")
    print("  3. MORTGAGE")
    print("  4. LIVING_WITH_PARENTS")
    home_choice = input("Select (1-4): ").strip() or "1"
    home_ownership = ["RENT", "OWN", "MORTGAGE", "LIVING_WITH_PARENTS"][int(home_choice) - 1]
    
    print("\nLoan Purpose:")
    print("  1. HOME")
    print("  2. CAR")
    print("  3. BUSINESS")
    print("  4. EDUCATION")
    print("  5. PERSONAL")
    purpose_choice = input("Select (1-5): ").strip() or "2"
    loan_purpose = ["HOME", "CAR", "BUSINESS", "EDUCATION", "PERSONAL"][int(purpose_choice) - 1]
    
    years_credit_history = float(input("\nYears of Credit History: ").strip() or "3")
    
    print("\nDefaults:")
    has_previous_defaults = input("Has Previous Defaults? (y/n): ").strip().lower() == 'y'
    currently_defaulting = input("Currently Defaulting? (y/n): ").strip().lower() == 'y'
    
    return {
        "full_name": full_name,
        "age": age,
        "monthly_income": monthly_income,
        "employment_status": employment_status,
        "years_employed": years_employed,
        "home_ownership": home_ownership,
        "loan_purpose": loan_purpose,
        "years_credit_history": years_credit_history,
        "has_previous_defaults": has_previous_defaults,
        "currently_defaulting": currently_defaulting
    }

def display_step1_result(data: Dict[str, Any]):
    """Display Step 1 results (loan limit)"""
    print(f"\n{Colors.HEADER}{'=' * 70}{Colors.ENDC}")
    print(f"{Colors.HEADER}STEP 1 RESULTS - LOAN LIMIT CALCULATION{Colors.ENDC}")
    print(f"{Colors.HEADER}{'=' * 70}{Colors.ENDC}\n")
    
    # Credit Score
    score = data['credit_score']
    if score >= 740:
        score_color = Colors.OKGREEN
        score_rating = "Excellent"
    elif score >= 700:
        score_color = Colors.OKCYAN
        score_rating = "Very Good"
    elif score >= 650:
        score_color = Colors.OKBLUE
        score_rating = "Good"
    else:
        score_color = Colors.WARNING
        score_rating = "Fair"
    
    print(f"{Colors.BOLD}Credit Score:{Colors.ENDC}")
    print(f"  {score_color}{score} / 850{Colors.ENDC} ({score_rating})")
    
    # Loan Limit
    limit = data['loan_limit_vnd']
    print(f"\n{Colors.BOLD}Maximum Loan Limit:{Colors.ENDC}")
    if data['approved']:
        print(f"  {Colors.OKGREEN}{format_currency(limit)}{Colors.ENDC}")
    else:
        print(f"  {Colors.FAIL}0 VND (Not Approved){Colors.ENDC}")
    
    # Risk Level
    risk = data['risk_level']
    risk_colors = {
        "Low": Colors.OKGREEN,
        "Medium": Colors.WARNING,
        "High": Colors.FAIL,
        "Very High": Colors.FAIL
    }   
    print(f"\n{Colors.BOLD}Risk Level:{Colors.ENDC}")
    print(f"  {risk_colors.get(risk, Colors.ENDC)}{risk}{Colors.ENDC}")
    
    # Message
    print(f"\n{Colors.BOLD}Message:{Colors.ENDC}")
    print(f"  {data['message']}")

def display_step2_result(data: Dict[str, Any], loan_amount: float):
    """Display Step 2 results (loan terms)"""
    print(f"\n{Colors.HEADER}{'=' * 70}{Colors.ENDC}")
    print(f"{Colors.HEADER}STEP 2 RESULTS - LOAN TERMS{Colors.ENDC}")
    print(f"{Colors.HEADER}{'=' * 70}{Colors.ENDC}\n")
    
    print(f"{Colors.BOLD}Loan Details:{Colors.ENDC}")
    print(f"  Amount: {Colors.OKGREEN}{format_currency(loan_amount)}{Colors.ENDC}")
    print(f"  Purpose: {Colors.OKCYAN}{data['loan_purpose']}{Colors.ENDC}")
    
    print(f"\n{Colors.BOLD}Interest Rate:{Colors.ENDC}")
    print(f"  {Colors.OKBLUE}{data['interest_rate']}% per year{Colors.ENDC}")
    print(f"  {data['rate_explanation']}")
    
    print(f"\n{Colors.BOLD}Loan Term:{Colors.ENDC}")
    years = data['loan_term_months'] // 12
    months = data['loan_term_months'] % 12
    term_str = f"{years} years" if months == 0 else f"{years} years {months} months"
    print(f"  {Colors.OKCYAN}{data['loan_term_months']} months ({term_str}){Colors.ENDC}")
    print(f"  {data['term_explanation']}")
    
    print(f"\n{Colors.BOLD}Monthly Payment:{Colors.ENDC}")
    print(f"  {Colors.OKGREEN}{format_currency(data['monthly_payment_vnd'])}{Colors.ENDC}")
    
    print(f"\n{Colors.BOLD}Total Payment:{Colors.ENDC}")
    print(f"  Total: {format_currency(data['total_payment_vnd'])}")
    print(f"  Interest: {format_currency(data['total_interest_vnd'])}")

def run_demo():
    """Run the demo"""
    print_header()
    
    # Check API connection
    try:
        response = requests.get(f"{API_BASE.replace('/api', '')}/api/health", timeout=5)
        if response.status_code != 200:
            print(f"{Colors.FAIL}Error: API is not responding properly{Colors.ENDC}")
            return
        print(f"{Colors.OKGREEN}API is running!{Colors.ENDC}\n")
    except requests.exceptions.RequestException:
        print(f"{Colors.FAIL}Error: Cannot connect to API at {API_BASE}{Colors.ENDC}")
        print(f"{Colors.WARNING}Make sure the API is running: uvicorn app.main:app --reload{Colors.ENDC}")
        return
    
    # Get customer input
    customer_data = get_customer_input()
    
    print(f"\n{Colors.OKCYAN}Processing...{Colors.ENDC}\n")
    
    # STEP 1: Calculate Loan Limit
    try:
        response = requests.post(CALCULATE_LIMIT_URL, json=customer_data)
        response.raise_for_status()
        step1_data = response.json()
        
        display_step1_result(step1_data)
        
        if not step1_data['approved']:
            print(f"\n{Colors.FAIL}Application rejected. Cannot proceed to Step 2.{Colors.ENDC}")
            return
        
    except requests.exceptions.RequestException as e:
        print(f"{Colors.FAIL}Error in Step 1: {e}{Colors.ENDC}")
        return
    
    # Ask user for loan amount
    print(f"\n{Colors.HEADER}{'=' * 70}{Colors.ENDC}")
    max_limit = step1_data['loan_limit_vnd']
    print(f"\n{Colors.BOLD}How much do you want to borrow?{Colors.ENDC}")
    print(f"Maximum: {Colors.OKGREEN}{format_currency(max_limit)}{Colors.ENDC}")
    
    loan_amount_input = input(f"\nEnter amount (VND) or press Enter for max: ").strip()
    if loan_amount_input:
        loan_amount = float(loan_amount_input)
        if loan_amount > max_limit:
            print(f"{Colors.WARNING}Amount exceeds limit. Using maximum: {format_currency(max_limit)}{Colors.ENDC}")
            loan_amount = max_limit
    else:
        loan_amount = max_limit
    
    # STEP 2: Calculate Loan Terms
    try:
        step2_request = {
            "loan_amount": loan_amount,
            "loan_purpose": customer_data['loan_purpose'],
            "credit_score": step1_data['credit_score']
        }
        
        response = requests.post(CALCULATE_TERMS_URL, json=step2_request)
        response.raise_for_status()
        step2_data = response.json()
        
        display_step2_result(step2_data, loan_amount)
        
    except requests.exceptions.RequestException as e:
        print(f"{Colors.FAIL}Error in Step 2: {e}{Colors.ENDC}")
        return
    
    # Summary
    print(f"\n{Colors.HEADER}{'=' * 70}{Colors.ENDC}")
    print(f"{Colors.OKGREEN}Application Complete!{Colors.ENDC}")
    print(f"{Colors.HEADER}{'=' * 70}{Colors.ENDC}\n")

def main():
    """Main function"""
    try:
        run_demo()
        
        print(f"\n{Colors.OKCYAN}Press Enter to exit...{Colors.ENDC}")
        input()
        
    except KeyboardInterrupt:
        print(f"\n\n{Colors.WARNING}Demo cancelled by user{Colors.ENDC}")
    except Exception as e:
        print(f"\n{Colors.FAIL}Unexpected error: {e}{Colors.ENDC}")

if __name__ == "__main__":
    main()
