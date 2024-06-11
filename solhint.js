module.exports = {
  rules: {
    /* Best Practise Rules */
    "max-states-count": ["warn", 15],
    "no-unused-vars": "error",
    "payable-fallback": "warn",
    "reason-string": ["error", { maxLength: 250 }],
    "constructor-syntax": "error",
    /* Style Guide Rules */
    quotes: ["error", "double"],
    "event-name-camelcase": "warn",
    "func-name-mixedcase": "warn",
    "use-forbidden-name": "error",
    "imports-on-top": "error",
    ordering: "warn",
    "visibility-modifier-order": "error",
    /* Security Rules */
    "avoid-call-value": "error",
    "avoid-low-level-calls": "error",
    "avoid-sha3": "error",
    "avoid-suicide": "error",
    "avoid-throw": "error",
    "avoid-tx-origin": "error",
    "check-send-result": "error",
    "func-visibility": ["error", { ignoreConstructors: true }],
    "multiple-sends": "error",
    "no-complex-fallback": "error",
    "no-inline-assembly": "error",
    "not-rely-on-block-hash": "error",
    "not-rely-on-time": "off",
    reentrancy: "error",
    "state-visibility": "error",
  },
};
// solhint -c solhint.js "contracts/**/*.sol"
