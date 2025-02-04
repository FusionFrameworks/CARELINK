const socketIO = require("socket.io");
const File = require("../models/fileModel");

let connectedClients = [];

const setupWebSocket = (server) => {
  const io = socketIO(server, {
    cors: {
      origin: "https://l7xqlqhl-3000.inc1.devtunnels.ms/", // Replace with the correct frontend URL
      methods: ["GET", "POST"],
    },
  });

  io.on("connection", (socket) => {
    console.log("New WebSocket client connected");
    connectedClients.push(socket);

    socket.on("disconnect", () => {
      console.log("WebSocket client disconnected");
      connectedClients = connectedClients.filter((client) => client !== socket);
    });

    socket.on("error", (err) => {
      console.error("Socket Error:", err);
    });
  });

  // Emit newly uploaded report to all clients
  const emitNewReport = async (fileId) => {
    try {
      const file = await File.findById(fileId);
      if (file) {
        io.emit("newReport", file);
        console.log("New Report emitted to clients:", file);
      }
    } catch (error) {
      console.error("Error emitting new report:", error);
    }
  };

  // Watch for changes in file uploads
  File.watch().on("change", async (change) => {
    if (change.operationType === "insert") {
      const newFileId = change.documentKey._id;
      await emitNewReport(newFileId);
    }
  });

  console.log("WebSocket server is set up");
};

module.exports = setupWebSocket;
