use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize)]
pub struct WorkerProfile {
    pub full_name: String,
    pub city: String,
    pub state: String,
    pub zip: String,
    pub pnw_name: String, // .pnw name input
    pub credential_data: Vec<String>, // Up to 5
}
