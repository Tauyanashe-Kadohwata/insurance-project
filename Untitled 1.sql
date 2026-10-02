SELECT
    COUNT(*) AS policies_with_claims,
    SUM(claim_count) AS total_claims,
    SUM(total_claim_amount) AS total_claim_amount
FROM INSURANCE_PROJECT.MARTS.POLICIES_SUMMARY
WHERE claim_count > 0;