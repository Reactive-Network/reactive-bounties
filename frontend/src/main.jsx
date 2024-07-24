import React from "react";
import ReactDOM from "react-dom/client";
import App from "./App.jsx";
import "./index.css";
// import { WagmiConfig, createConfig, configureChains } from "wagmi";
// import { mainnet, sepolia } from "wagmi/chains";
// import {
//   ConnectKitProvider,
//   ConnectKitButton,
//   getDefaultConfig,
// } from "connectkit";

// const config = createConfig(
//   getDefaultConfig({
//     // Required API Keys
//     alchemyId: import.meta.env.VITE_ALCHEMYID, // or infuraId
//     walletConnectProjectId: import.meta.env.VITE_WALLETCONNECTID,

//     // Required
//     appName: "DEMO",
//     chains: [sepolia],
//   })
// );

ReactDOM.createRoot(document.getElementById("root")).render(<App />);
