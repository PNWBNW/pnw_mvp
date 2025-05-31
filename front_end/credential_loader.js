// credential_loader.js

/**
 * Loads and parses a credential JSON file for use in Aleo submissions.
 * Expected fields: credential_hash, edition, (optional: name, state, city, zip, etc)
 */

export async function loadCredentialJSON(fileInputId) {
  const input = document.getElementById(fileInputId);
  if (!input || !input.files || input.files.length === 0) {
    throw new Error('No credential file selected.');
  }

  const file = input.files[0];
  const text = await file.text();
  let parsed;

  try {
    parsed = JSON.parse(text);
  } catch (e) {
    throw new Error('Invalid JSON format in credential file.');
  }

  // Required fields
  if (!parsed.credential_hash || !parsed.edition) {
    throw new Error('Missing required fields: credential_hash and edition.');
  }

  const credentialHash = parsed.credential_hash;
  const edition = parsed.edition;

  // Optional fields
  const name = parsed.name || null;
  const state = parsed.state || null;
  const city = parsed.city || null;
  const zip = parsed.zip || null;

  return {
    credentialHash,
    edition,
    name,
    state,
    city,
    zip
  };
}
