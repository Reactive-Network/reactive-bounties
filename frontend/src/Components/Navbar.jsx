import React, { useState } from "react";
import { NavLink, Link } from "react-router-dom";
import "./navbar.css";
import logo from "../assets/nftance.png";
import { useEffect } from "react";
import { ethers } from "ethers";

// import {
//   ConnectKitProvider,
//   ConnectKitButton,
//   getDefaultConfig,
// } from "connectkit";
// import logo from "../images/logo.png";

const Navbar = () => {
  const [address, setaddress] = useState("");

  const loadAddress = async () => {
    const provider = new ethers.BrowserProvider(window.ethereum);

    const log = await provider.send("eth_requestAccounts", []);
    console.log(log);
    const signer = await provider.getSigner();
    const add = await signer.getAddress();
    setaddress(add);
    console.log(add);
  };

  useEffect(() => {
    loadAddress();
  }, []);

  return (
    <div className="gpt3__navbar">
      <div className="gpt3__navbar-links">
        <div className="gpt3__navbar-links_logo">
          <Link to="/">
            {/* <img src={logo}></img> */}
            <h2>
              ERC <span>6551</span>
            </h2>
          </Link>
        </div>
      </div>

      <div className="gpt3__navbar-sign">
        <button
          type="button"
          className="navbar_my_nft_button_add"
          onClick={loadAddress}
        >
          {address
            ? `${address?.slice(0, 6)}...${address?.slice(
                address.length - 4,
                address.length
              )}`
            : "Connect wallet"}
        </button>

        <Link to="/nft">
          <button type="button" className="navbar_my_nft_button">
            My NFTs{" "}
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512">
              <path
                fill="#ffffff"
                d="M502.6 278.6c12.5-12.5 12.5-32.8 0-45.3l-128-128c-12.5-12.5-32.8-12.5-45.3 0s-12.5 32.8 0 45.3L402.7 224 32 224c-17.7 0-32 14.3-32 32s14.3 32 32 32l370.7 0-73.4 73.4c-12.5 12.5-12.5 32.8 0 45.3s32.8 12.5 45.3 0l128-128z"
              />
            </svg>
          </button>
        </Link>
      </div>
    </div>
  );
};

export default Navbar;
