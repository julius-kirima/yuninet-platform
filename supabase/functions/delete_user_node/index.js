require('dotenv').config(); // Load .env file

const express = require('express');
const { createClient } = require('@supabase/supabase-js');

const app = express();
app.use(express.json());

// DEBUG: Show values from .env
console.log("🔍 SUPABASE_URL:", process.env.SUPABASE_URL);
console.log("🔍 SUPABASE_SERVICE_ROLE_KEY:", process.env.SUPABASE_SERVICE_ROLE_KEY ? "Loaded ✅" : "❌ Not Found");
console.log("🔍 PORT:", process.env.PORT);

// Load credentials from .env
const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!supabaseUrl || !supabaseKey) {
  console.error("❌ Missing Supabase credentials in .env");
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseKey);

// DELETE user route
app.post('/delete-user', async (req, res) => {
  const { user_id } = req.body;

  if (!user_id) {
    return res.status(400).json({ error: '❌ Missing user_id in request body.' });
  }

  try {
    const { error } = await supabase.auth.admin.deleteUser(user_id);

    if (error) {
      return res.status(500).json({ error: error.message });
    }

    res.json({ message: '✅ User deleted successfully.' });
  } catch (err) {
    console.error("❌ Internal Error:", err);
    res.status(500).json({ error: '❌ Internal server error.' });
  }
});

// Start the server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 Server running at http://localhost:${PORT}`);
});
