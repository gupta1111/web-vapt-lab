const express = require("express");
const path = require("path");

const app = express();
const PORT = 4000;

app.use(express.json());
app.use(express.static(path.join(__dirname, "public")));

app.get("/api/health", (req, res) => {
    res.json({
        status: "online",
        application: "AI VAPT Dashboard",
        version: "1.0.0"
    });
});

app.listen(PORT, "127.0.0.1", () => {
    console.log(`AI VAPT Dashboard running at http://127.0.0.1:${PORT}`);
});
