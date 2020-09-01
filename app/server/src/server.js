// server/src/server.js
const express = require("express");
const mongoose = require("mongoose");

// Assign environment variables
const port = process.env.PORT || 4000;
const mongoUri = process.env.MONGO_URI || "mongodb://localhost:27017/test";


const Prometheus = require('prom-client');

// create metrics for Prometheus

const metricsInterval = Prometheus.collectDefaultMetrics()

const appCallsTotal = new Prometheus.Counter({
    name: 'MERN_APP_web_app_calls',
    help: 'Number of times the server API was called by the client'
});

const dbCallsFailTotal = new Prometheus.Counter({
    name: 'MERN_APP_db_connection_failures',
    help: 'Total number of server->db connection failures'
})

const dbCallsSuccessTotal = new Prometheus.Counter({
    name: 'MERN_APP_db_connection_successes',
    help: 'Total number of server->db connection successes'
})
const metricsReadTotal = new Prometheus.Counter({
    name: 'MERN_APP_metrics_read_total',
    help: 'Total number of metric readings'
})

const httpRequestDurationMicroseconds = new Prometheus.Histogram({
    name: 'MERN_APP_http_request_duration_ms',
    help: 'Duration of HTTP requests in ms',
    labelNames: ['method', 'route', 'code'],
    buckets: [0.10, 5, 15, 50, 100, 200, 300, 400, 500] // buckets for response time from 0.1ms to 500ms
})

// Initiliase an express server
const app = express();

/**
 * Setup services
 */

// Options to pass to mongodb to avoid deprecation warnings
const options = {
    useNewUrlParser: true
};

// Function to connect to the database
const conn = () => {
    mongoose.connect(
        mongoUri,
        options
    );
};
// Call it to connect
conn();

// Handle the database connection and retry as needed
const db = mongoose.connection;
db.on("error", err => {
    console.log("There was a problem connecting to the database: ", err);
    console.log("Please trying again");
    dbCallsFailTotal.inc(); // db connection fail counter metric
    setTimeout(() => conn(), 5000);
});

db.once("open", () => {
    dbCallsSuccessTotal.inc(); // db connection counter metric
    console.log("Successfully connected to the database")
});

// Setup routes to respond to client
app.get("/welcome", async(req, res) => {
    console.log("Client request received");
    const user = await User.find().exec();
    console.log(user[0].name);
    appCallsTotal.inc(); // page counter metric

    res.send(
        `Hello Client! There is one record in the database for ${user[0].name}`
    );
});

app.get("/metrics", (req, res) => {
    metricsReadTotal.inc(); // metric readings counter metric
    res.set('Content-Type', Prometheus.register.contentType);
    res.send(Prometheus.register.metrics());
});

// Setup a record in the database to retrieve
const {
    Schema
} = mongoose;
const userSchema = new Schema({
    name: String
}, {
    timestamps: true
});
const User = mongoose.model("User", userSchema);
const user = new User({
    name: "Pedro Tavares"
});
user
    .save()
    .then(user => console.log(`${user.name} saved to the database`))
    .catch(err => console.log(err));

app.listen(port, () => console.log(`Listening on port ${port}`));