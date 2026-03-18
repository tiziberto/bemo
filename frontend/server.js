const express = require("express")
const axios = require("axios")

const app = express()

app.get("/test", async (req, res) => {
  try {
    const response = await axios.get("http://localhost:8080/api/hola")

    res.json({
      mensaje: "Node conectado con Spring Boot",
      backend: response.data
    })
  } catch (error) {
    res.json({
      error: "No se pudo conectar al backend"
    })
  }
})

app.listen(3000, () => {
  console.log("Servidor Node corriendo en puerto 3000")
})

