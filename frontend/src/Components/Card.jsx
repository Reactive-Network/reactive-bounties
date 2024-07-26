import React from "react";
import { useNavigate } from "react-router-dom";
// import ContentCopyIcon from "@mui/icons-material/ContentCopy";
import img1 from "../assets/img2.jpg";
import "./card.css";
import { toast, ToastContainer } from "react-toastify";
import "react-toastify/dist/ReactToastify.css";

const Card = ({ name, index, address, img }) => {
  const navigate = useNavigate();

  const handleClick = () => {
    console.log("asddada");
    console.log(index, address);
    navigate(`/nft/${address}/${index}`);
  };

  const copyToClipboard = () => {
    navigator.clipboard.writeText(address);
    toast.success(`Copied ${address?.slice(0, 10)}...`, {
      position: "bottom-right",
    });
  };

  return (
    // https://eth-sepolia.g.alchemy.com/nft/v2/6ToPbDTF5nhiVtF7Zb1eE4fTdZ2_Wrkk/getNFTMetadata?contractAddress=0xA1436b27e514DCD0ab633b9626FC730f5fbCCd2e&tokenId=3&refreshCache=true

    <div className="card_container">
      <div className="card_container_img" onClick={handleClick}>
        {img ? <img src={img}></img> : <img src={img1}></img>}
      </div>
      <div className="card_container_body">
        <div className="card_container_body_upper">
          <div>{name}</div>
          <div>#{index}</div>
        </div>
        <div className="card_container_body_lower">
          {/* <div>{address}</div> */}
          <p
            className="card_container_body_lower_add"
            onClick={copyToClipboard}
          >
            {address?.slice(0, 7)}...
            {address?.slice(address.length - 4, address.length)}
            <svg
              xmlns="http://www.w3.org/2000/svg"
              xmlns:xlink="http://www.w3.org/1999/xlink"
              aria-hidden="true"
              role="img"
              class="w-4 h-4 iconify iconify--mingcute"
              width="1em"
              height="1em"
              viewBox="0 0 24 24"
            >
              <g fill="none">
                <path d="M24 0v24H0V0zM12.593 23.258l-.011.002l-.071.035l-.02.004l-.014-.004l-.071-.035c-.01-.004-.019-.001-.024.005l-.004.01l-.017.428l.005.02l.01.013l.104.074l.015.004l.012-.004l.104-.074l.012-.016l.004-.017l-.017-.427c-.002-.01-.009-.017-.017-.018m.265-.113l-.013.002l-.185.093l-.01.01l-.003.011l.018.43l.005.012l.008.007l.201.093c.012.004.023 0 .029-.008l.004-.014l-.034-.614c-.003-.012-.01-.02-.02-.022m-.715.002a.023.023 0 0 0-.027.006l-.006.014l-.034.614c0 .012.007.02.017.024l.015-.002l.201-.093l.01-.008l.004-.011l.017-.43l-.003-.012l-.01-.01z"></path>
                <path
                  fill="currentColor"
                  d="M19 2a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2h-2v2a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h2V4a2 2 0 0 1 2-2zm-4 6H5v12h10zm-5 7a1 1 0 1 1 0 2H8a1 1 0 1 1 0-2zm9-11H9v2h6a2 2 0 0 1 2 2v8h2zm-7 7a1 1 0 0 1 .117 1.993L12 13H8a1 1 0 0 1-.117-1.993L8 11z"
                ></path>
              </g>
            </svg>
          </p>
        </div>
      </div>
    </div>
  );
};

export default Card;
