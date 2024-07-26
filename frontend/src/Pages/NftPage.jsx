import React, { useEffect, useState } from "react";
import "./nftpage.css";
import originabi from "../ERC_6551_Origin.json";
import registryabi from "../ERC_6551_registry.json";
import { ethers } from "ethers";
import { useParams } from "react-router-dom";
import img1 from "../assets/img2.jpg";
import { toast, ToastContainer } from "react-toastify";
import "react-toastify/dist/ReactToastify.css";
import axios from "axios";
import { styled } from "@mui/material/styles";
import Table from "@mui/material/Table";
import TableBody from "@mui/material/TableBody";
import TableCell, { tableCellClasses } from "@mui/material/TableCell";
import TableContainer from "@mui/material/TableContainer";
import TableHead from "@mui/material/TableHead";
import TableRow from "@mui/material/TableRow";
import Paper from "@mui/material/Paper";
import { useNavigate } from "react-router-dom";

// const DataDisplay = ({ data }) => {
//   return (
//     <div>
//       <h2>Data Display Component</h2>
//       <p>{data}</p>
//     </div>
//   );
// };

const StyledTableCell = styled(TableCell)(({ theme }) => ({
  [`&.${tableCellClasses.head}`]: {
    backgroundColor: "#0d0d0d",
    color: theme.palette.common.white,
  },
  [`&.${tableCellClasses.body}`]: {
    fontSize: 14,
  },
}));

const StyledTableRow = styled(TableRow)(({ theme }) => ({
  "&:nth-of-type(odd)": {
    backgroundColor: theme.palette.action.hover,
  },
  // hide last border
  "&:last-child td, &:last-child th": {
    border: 0,
  },
}));

const NftPage = () => {
  const navigate = useNavigate();
  const [nftList, setNftlist] = useState([]);
  const [TBAaddress, setTBAaddress] = useState();
  // const [owneraddress, setowneraddress] = useState();
  // const [chainid, setchainid] = useState();
  const { address, index } = useParams();
  const [Contract, setContract] = useState();
  const [chainid, setchainid] = useState();
  const [selectedDiv, setSelectedDiv] = useState();
  const [isSepolia, setIsSepolia] = useState(false);
  const [isBase, setIsBase] = useState(false);
  const [isOptimism, setIsOptimism] = useState(false);
  const [detail, setDetail] = useState([]);

  
  const loadData = async () => {
    const options = { method: "GET" };
   

    let jsonresponse;
    const provider = new ethers.BrowserProvider(window.ethereum);
    const { chainId } = await provider.getNetwork();
    const signer = await provider.getSigner();

    const contract = new ethers.Contract(
      "0x1F8Ef4238f567289706b5AAF2fF073f929e2B331",
      originabi,
      signer
    );
    
    setContract(contract);
    setchainid(chainId);

    if (chainId == 11155111) {
      // sepolia
      const response = await fetch(
        `https://eth-sepolia.g.alchemy.com/nft/v2/6ToPbDTF5nhiVtF7Zb1eE4fTdZ2_Wrkk/getNFTMetadata?contractAddress=${address}&tokenId=${index}&refreshCache=true`,
        options
      );
      jsonresponse = await response.json();
      console.log("all nft", jsonresponse);
      setNftlist(jsonresponse);
    } 

    

    const Registrycontract = new ethers.Contract(
      "0xd3e5df617898d2f9eBBCbc4C5174B83BB61d224A",
      registryabi,
      signer
    );

    const accountAddress = await Registrycontract.account(
      11155111,
      jsonresponse.contract.address,
      jsonresponse.id.tokenId,
      7000
    );
    console.log(accountAddress);
    setTBAaddress(accountAddress);
    setIsSepolia(
      await Registrycontract.isAccountCreated(
        11155111,
        jsonresponse.contract.address,
        jsonresponse.id.tokenId,
        7000
      )
    );
    console.log(await Registrycontract.isAccountCreated(
      11155111,
      jsonresponse.contract.address,
      jsonresponse.id.tokenId,
      7000
    ));

    setIsBase(
      false
    );

    setIsOptimism(
      false
    );

    // console.log(accountAddress);
  };

  const loadDetails = async (address, urlnetwork) => {
    const data = {
      jsonrpc: "2.0",
      method: "alchemy_getAssetTransfers",
      params: [
        {
          fromBlock: "0x0",
          toBlock: "latest",
          category: ["external", "erc20", "erc721", "erc1155", "internal"],
          // fromAddress: "0xfddD2b8D9aaf04FA583CCF604a2De12668200582",
          fromAddress: address,
        },
      ],
    };
    const response = await axios.post(
      `https://${urlnetwork}.g.alchemy.com/v2/6ToPbDTF5nhiVtF7Zb1eE4fTdZ2_Wrkk`,
      data
    );
    setDetail(response?.data?.result?.transfers);
    console.log("loadDetails", response?.data?.result?.transfers);
  };

  useEffect(() => {
    loadData().then(() => {
      TBAaddress&&loadDetails(TBAaddress, "eth-sepolia");
    });
  }, []);

  const handleClickBase = async () => {
    toast.error("This feature is not available yet");
  };

  const handleClickSepolia = async () => {
    setSelectedDiv("div1");
    if (!isSepolia) {
      // const contract=new ethers.Contract("")
      if (chainid == 11155111) {
        const tx = await Contract.createAccount(
          11155111,
          nftList.contract.address,
          nftList.id.tokenId,
        );
        await tx.wait();
        console.log("deployed on sepolia");
      } 
    } else {
      TBAaddress&&loadDetails(TBAaddress, "eth-sepolia");
    }
  };

  const handleClickOptimisum = async () => {
    toast.error("This feature is not available yet");
  };

  const copyToClipboard = () => {
    navigator.clipboard.writeText(TBAaddress);
    toast.success(`Copied ${TBAaddress.slice(0, 10)}...`, {
      position: "bottom-right",
    });
  };

  const openSeaURL = `https://testnets.opensea.io/assets/${
    chainid == 84532
      ? "base-sepolia"
      : chainid == 11155420
      ? "op-sepolia"
      : "sepolia"
  }/${address}/${index}`;

  return (
    <>
      <div className="nftpage_container">
        <div className="nftpage_container_left">
          {nftList?.metadata?.image ? (
            <img src={nftList?.metadata?.image}></img>
          ) : (
            <img src={img1}></img>
          )}

          <div className="nftpage_container_left_detail">
            <p>{nftList?.title}</p>
            <a href={openSeaURL} target="_blank" rel="noopener noreferrer">
              <img src="https://tokenbound.org/_next/image?url=%2Fopensea.svg&w=32&q=75"></img>
            </a>
          </div>
        </div>
        <div className="nftpage_container_right">
          <div className="nftpage_container_right_header">
            <div
              className="nftpage_container_right_header_left"
              onClick={copyToClipboard}
            >
              {TBAaddress?.slice(0, 7)}...
              {TBAaddress?.slice(TBAaddress.length - 5, TBAaddress.length)}
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
            </div>
            {/* <div className="nftpage_container_right_header_right">
              <button
                class="rounded-lg px-4 py-2 font-hl text-xs transition hover:scale-105 hover:hue-rotate-15 lg:text-base nftpage_container_button1"
                fdprocessedid="bjbj5g"
              >
                Depoly on optimisum
              </button>
              <button
                class="rounded-lg bg-gradient-to-r from-[#6C55F9] to-[#9D55F9] px-4 py-2 font-hl text-xs text-white transition hover:scale-105 hover:hue-rotate-15 lg:text-base nftpage_container_button2"
                fdprocessedid="bjbj5g"
              >
                Depoly on sepolia
              </button>
            </div> */}
          </div>

          <div className="nftpage_container_right_body">
            <div
              onClick={() => handleClickSepolia()}
              className={selectedDiv === "div1" ? "selected" : "non-selected"}
            >
              {isSepolia ? "Sepolia" : "Depoly on sepolia"}
              {/* Depoly on sepolia */}
            </div>
            <div
              onClick={() => handleClickBase()}
              className={selectedDiv === "div2" ? "selected" : "non-selected"}
            >
              {isBase ? "Base-sepolia" : "Depoly on base-sepolia"}
              {/* Depoly on base-sepolia */}
            </div>
            <div
              onClick={() => handleClickOptimisum()}
              className={selectedDiv === "div3" ? "selected" : "non-selected"}
            >
              {isOptimism ? "op-sepolia" : "Depoly on op-sepolia"}

              {/* Depoly on op-sepolia */}
            </div>
          </div>

          {/* {selectedDiv && <DataDisplay data={divData[selectedDiv]} />} */}
          {nftList.length===0 ? (
            <div className="no_tran">No transaction has executed yet.</div>
          ) : (
            <div className="nftpage_tran_container">
              {detail.map((k) => (
                <div className="nftpage_div">
                  <div className="right_div_first">
                    <div className="nftpage_div_first_svg">
                      <svg
                        xmlns="http://www.w3.org/2000/svg"
                        viewBox="0 0 512 512"
                      >
                        <path
                          // fill="#ffffff"
                          d="M64 32C28.7 32 0 60.7 0 96v64c0 35.3 28.7 64 64 64H448c35.3 0 64-28.7 64-64V96c0-35.3-28.7-64-64-64H64zm280 72a24 24 0 1 1 0 48 24 24 0 1 1 0-48zm48 24a24 24 0 1 1 48 0 24 24 0 1 1 -48 0zM64 288c-35.3 0-64 28.7-64 64v64c0 35.3 28.7 64 64 64H448c35.3 0 64-28.7 64-64V352c0-35.3-28.7-64-64-64H64zm280 72a24 24 0 1 1 0 48 24 24 0 1 1 0-48zm56 24a24 24 0 1 1 48 0 24 24 0 1 1 -48 0z"
                        />
                      </svg>
                    </div>
                    <div>
                      <p>
                        From{" "}
                        <span>
                          {k?.from?.slice(0, 4)}...
                          {k?.from?.slice(k?.from?.length - 6, k?.from?.length)}
                        </span>
                      </p>
                      <p>Value {k?.value}</p>
                    </div>
                  </div>
                  <div className="nftpage_div_second">
                    <p>
                      To{" "}
                      <span>
                        {k?.to?.slice(0, 4)}...
                        {k?.to?.slice(k?.to?.length - 6, k?.to?.length)}
                      </span>
                    </p>
                  </div>
                  <div className="nftpage_div_third">
                    Tx hash <span>{k?.hash.slice(0, 8)}...</span>
                  </div>
                </div>
              ))}
            </div>
            // <TableContainer component={Paper}>
            //   <Table sx={{ minWidth: 700 }} aria-label="customized table">
            //     <TableHead>
            //       <TableRow>
            //         <StyledTableCell>From</StyledTableCell>
            //         <StyledTableCell align="left">To</StyledTableCell>
            //         <StyledTableCell align="left">Value</StyledTableCell>
            //       </TableRow>
            //     </TableHead>
            //     <TableBody>

            // {detail.map((row) => (
            //   <StyledTableRow key={row.name}>
            //     <StyledTableCell component="th" scope="row">
            //       {row?.from?.slice(0, 10)}
            //     </StyledTableCell>
            //     <StyledTableCell align="left">
            //       {row?.to?.slice(0, 10)}
            //     </StyledTableCell>
            //     <StyledTableCell align="left">
            //       {row?.value}
            //     </StyledTableCell>
            //   </StyledTableRow>
            // ))}
            // </TableBody>
            // </Table>
            // </TableContainer>
          )}
        </div>
      </div>
    </>
  );
};

export default NftPage;
