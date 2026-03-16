___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "MACRO",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Simple encryption",
  "description": "A \u003cb\u003every\u003c/b\u003e simple \"encrypt\"/\"decrypt\" model for obfuscating strings. Does not require external resources. \u003cb\u003eNot safe for critical information, fairly easy to decode.\u003c/b\u003e",
  "containerContexts": [
    "SERVER"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "TEXT",
    "name": "input",
    "displayName": "Input value",
    "simpleValueType": true,
    "alwaysInSummary": true
  },
  {
    "type": "TEXT",
    "name": "key",
    "displayName": "Encryption key",
    "simpleValueType": true,
    "alwaysInSummary": true,
    "defaultValue": "The answer is 42",
    "help": "Make it loooong. The longer, the better. Like \u003cb\u003eminimum\u003c/b\u003e 32 characters long. But even longer is better.\u003cbr\u003e\u003cbr\u003e\n\nAim for \u003cmark\u003eSTRONG\u003c/mark\u003e on \u003ca href\u003d\"https://bitwarden.com/password-strength/#Password-Strength-Testing-Tool\" target\u003d\"_blank\"\u003eBitwarden\u0027s Password Strength Tester\u003c/a\u003e.\n\n(\u003cb\u003eNote:\u003c/b\u003e The key needs to be \u003ci\u003eat least\u003c/i\u003e 4 characters long otherwise the variable will return `undefined`.)"
  },
  {
    "type": "RADIO",
    "name": "method",
    "displayName": "Method",
    "radioItems": [
      {
        "value": "encrypt",
        "displayValue": "Encrypt"
      },
      {
        "value": "decrypt",
        "displayValue": "Decrypt"
      }
    ],
    "simpleValueType": true,
    "defaultValue": "encrypt"
  }
]


___SANDBOXED_JS_FOR_SERVER___

const logToConsole = require('logToConsole');
const toBase64 = require('toBase64');
const fromBase64 = require('fromBase64');

const ALPHABET = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_';
const ALPHA_LEN = ALPHABET.length;
const MOD32 = 4294967296;

// --- Input validation ---
const original = data.input;
const key = data.key;
const method = data.method;

if (!original || !key || !method) {
  logToConsole('[Cipher] Missing required field(s): input, key, or method');
  return undefined;
}

if (key.length < 4) {
  logToConsole('[Cipher] Key too short (minimum 4 characters)');
  return undefined;
}

// --- Helpers ---

function toUint32(n) {
  return ((n % MOD32) + MOD32) % MOD32;
}

function hashKey(k) {
  let h = 0;
  for (let round = 0; round < 3; round++) {
    for (let i = 0; i < k.length; i++) {
      let idx = ALPHABET.indexOf(k[i]);
      if (idx === -1) idx = i + 1;
      h = toUint32(h * 31 + idx + round * 7);
    }
  }
  return h;
}

function nextRandom(seed) {
  return toUint32(seed * 1664525 + 1013904223);
}

function generateShifts(k, length) {
  let seed = hashKey(k);
  let shifts = [];
  for (let i = 0; i < length; i++) {
    seed = nextRandom(seed);
    shifts.push(seed % ALPHA_LEN);
  }
  return shifts;
}

// --- Base64 URL-safe conversion ---

function toUrlSafeB64(str) {
  let b64 = toBase64(str);
  if (!b64) return '';
  let out = '';
  for (let i = 0; i < b64.length; i++) {
    if (b64[i] === '+') out += '-';
    else if (b64[i] === '/') out += '_';
    else if (b64[i] !== '=') out += b64[i];
  }
  return out;
}

function fromUrlSafeB64(str) {
  let out = '';
  for (let i = 0; i < str.length; i++) {
    if (str[i] === '-') out += '+';
    else if (str[i] === '_') out += '/';
    else out += str[i];
  }
  let remainder = out.length % 4;
  if (remainder === 2) out += '==';
  else if (remainder === 3) out += '=';
  return fromBase64(out);
}

// --- Encrypt / Decrypt ---

function encrypt(text, k) {
  let b64 = toUrlSafeB64(text);
  let shifts = generateShifts(k, b64.length);
  let output = '';
  for (let i = 0; i < b64.length; i++) {
    let pos = ALPHABET.indexOf(b64[i]);
    if (pos === -1) {
      output += b64[i];
      continue;
    }
    let keyPos = ALPHABET.indexOf(k[i % k.length]);
    if (keyPos === -1) keyPos = 0;
    output += ALPHABET[(pos + keyPos + shifts[i]) % ALPHA_LEN];
  }
  return output;
}

function decrypt(text, k) {
  let shifts = generateShifts(k, text.length);
  let output = '';
  for (let i = 0; i < text.length; i++) {
    let pos = ALPHABET.indexOf(text[i]);
    if (pos === -1) {
      output += text[i];
      continue;
    }
    let keyPos = ALPHABET.indexOf(k[i % k.length]);
    if (keyPos === -1) keyPos = 0;
    output += ALPHABET[((pos - keyPos - shifts[i]) % ALPHA_LEN + ALPHA_LEN) % ALPHA_LEN];
  }
  return fromUrlSafeB64(output);
}

// --- Execute ---

if (method === 'encrypt') {
  return encrypt(original, key);
} else if (method === 'decrypt') {
  return decrypt(original, key);
} else {
  logToConsole('[Cipher] Invalid method: use "encrypt" or "decrypt"');
  return undefined;
}


___SERVER_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "logging",
        "versionId": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "debug"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  }
]


___TESTS___

scenarios:
- name: Encrypt
  code: |-
    const mockData = {
      // Mocked field values
      input: "taggingwise.com",
      method: "encrypt",
      key: "The answer is 42"
    };

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    assertThat(variableResult).isEqualTo('usDmFmlBdvlSCHIP5sL8');
- name: Decrypt
  code: |-
    const mockData = {
      // Mocked field values
      input: "usDmFmlBdvlSCHIP5sL8",
      method: "decrypt",
      key: "The answer is 42"
    };

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    assertThat(variableResult).isEqualTo('taggingwise.com');


___NOTES___

Created on 16.3.2026, 16.17.48


