const http = require("http");
const app = require("./app"); // Import Express app
const setupWebSocket = require("./utils/websocket"); // Import WebSocket setup

// Create HTTP server
const server = http.createServer(app);

// Set up WebSocket
setupWebSocket(server);

// Start the server
const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
