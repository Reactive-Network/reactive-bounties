import { ethers } from "ethers";
import React from "react";
import { useState } from "react";
import { useEffect } from "react";
import { Link } from "react-router-dom";

const Home = () => {
  
  return (
    <div>
      <div class="mx-auto max-w-[1800px] px-4 sm:px-6 lg:px-24">
        <section class="w-full py-12 space-y-6">
          <div class="font-sans font-semibold text-3xl text-center md:text-5xl">
            crosschain ERC 6551 token bounded account
          </div>
          <div
            className="font-sans text-xl text-center md:text-2xl"
            style={{ color: "#65b5db" }}
          >
            Unlocking potential for cross chain token bounded account.
          </div>

          <video
            src="https://tokenbound.org/homepage/homepage_hero.mp4"
            autoPlay
            loop
            playsInline
            muted
            className="rounded-xl md:block"
          ></video>
        </section>
      </div>

      <section
        className="w-full md:h-[85vh] bg-right-top bg-no-repeat bg-contain"
        style={{
          backgroundImage:
            'url("https://tokenbound.org/homepage/bg-swirl-small.png")',
        }}
      >
        <div className="flex flex-col-reverse items-center h-full py-12 md:flex-row">
          <div className="flex items-end justify-center w-full h-full md:w-1/2">
            <div className="md:w-[80%] pt-12 md:pt-0 px-4 md:px-0">
              <div className="hidden md:block">
                <div className="text-2xl md:text-3xl font-sans font-semibold">
                  crosschain ERC-6551 unlocks potential for
                  <span style={{ color: "#65b5db" }}>
                    {" "}
                    cross chain token bounded account.
                  </span>
                </div>
                {/* <div className="text-2xl md:text-3xl font-sans font-semibold">
                  life with
                  <span className="text-gradient-purple">
                    token bound accounts
                  </span>
                </div> */}
              </div>
              <div className="md:hidden">
                <div className="text-2xl md:text-3xl font-sans font-semibold">
                   crosschain ERC-6551 brings your NFTs to life with
                  <span>token bound accounts</span>
                </div>
              </div>
              <div className="flex items-center pt-6 space-x-4 md:pt-20">
                <div className="text-xs font-mono text-zinc-400 py-4 uppercase w-fit whitespace-nowrap">
                  with crosschain ERC-6551, your NFT can
                </div>
                <div className="w-full h-0 border-t border-zinc-500"></div>
              </div>
              <div class="grid grid-cols-2 gap-4">
                <div class="flex flex-col justify-center p-4 space-y-2 border border-white rounded-lg bg-zinc-50">
                  <div class="text-base font-mono uppercase text-gradient-purple">
                    <span>Own Assets cross chain</span>
                  </div>
                  <div class="text-heading">Use your NFTs like a wallet</div>
                </div>
                <div class="flex flex-col justify-center p-4 space-y-2 border border-white rounded-lg bg-zinc-50">
                  <div class="text-base font-mono uppercase text-gradient-purple">
                    <span>MAKE ONCHAIN HISTORY</span>
                  </div>
                  <div class="text-heading">Take actions with your NFT</div>
                </div>
                <div class="flex flex-col justify-center p-4 space-y-2 border border-white rounded-lg bg-zinc-50">
                  <div class="text-base font-mono uppercase text-gradient-purple">
                    <span>Create token bounded account</span>
                  </div>
                  <div class="text-heading">Use your NFT as an identity</div>
                </div>
                <div class="flex flex-col justify-center p-4 space-y-2 border border-white rounded-lg bg-zinc-50">
                  <div class="text-base font-mono uppercase text-gradient-purple">
                    <span>live cross-chain</span>
                  </div>
                  <div class="text-heading">See your NFTs in action</div>
                </div>
              </div>
              <div className="flex items-center pt-12 space-x-4">
                <div className="text-base font-sans text-zinc-600">
                  See your NFTs in action
                </div>
                <Link to="/nft">
                  <button type="button" className="navbar_my_nft_button">
                    Get started{" "}
                    <svg
                      xmlns="http://www.w3.org/2000/svg"
                      viewBox="0 0 512 512"
                    >
                      <path
                        fill="#ffffff"
                        d="M502.6 278.6c12.5-12.5 12.5-32.8 0-45.3l-128-128c-12.5-12.5-32.8-12.5-45.3 0s-12.5 32.8 0 45.3L402.7 224 32 224c-17.7 0-32 14.3-32 32s14.3 32 32 32l370.7 0-73.4 73.4c-12.5 12.5-12.5 32.8 0 45.3s32.8 12.5 45.3 0l128-128z"
                      />
                    </svg>
                  </button>
                </Link>
              </div>
            </div>
          </div>
          <div className="w-full md:w-1/2">
            <div className="flex justify-end w-full">
              <div>
                <img
                  alt=""
                  loading="lazy"
                  width="1396"
                  height="1166"
                  decoding="async"
                  data-nimg="1"
                  style={{ color: "transparent" }}
                  srcSet="https://tokenbound.org/_next/image?url=%2Fhomepage%2Fintro.png&w=3840&q=75 1x, https://tokenbound.org/_next/image?url=%2Fhomepage%2Fintro.png&w=3840&q=75 2x"
                  src="https://tokenbound.org/_next/image?url=%2Fhomepage%2Fintro.png&w=3840&q=75"
                />
              </div>
            </div>
          </div>
        </div>
      </section>
      {/* <div class="mx-auto max-w-[1800px] px-4 sm:px-6 lg:px-24">
        <div class="flex flex-col-reverse items-center py-12 md:flex-row">
          <div class="pt-12 md:pt-0 md:pr-24 md:w-1/2">
            <div class="text-xs font-mono text-zinc-400 uppercase">
              For project owners
            </div>
            <div class="text-2xl md:text-3xl font-sans font-semibold">
              Airdrop directly to an NFTs
            </div>
            <div class="text-2xl md:text-3xl font-sans font-semibold">
              token bound account
            </div>
            <div class="pt-4">
              <div class="text-base font-sans text-zinc-600">
                Get a list of your community{" "}
                <span class="font-bold text-gradient-purple">
                  token bound account addresses
                </span>
                . Airdrop directly to NFT accounts, retroactively form DAOs and
                reach holders no matter how quickly NFTs change hands.
              </div>
              <div class="w-full py-6">
                <div class="w-full md:w-1/2">
                  <div class="relative">
                    <div class="relative rounded-md ">
                      <div class="absolute inset-y-0 flex items-center pr-3 pointer-events-none left-4">
                        <svg
                          xmlns="http://www.w3.org/2000/svg"
                          width="24"
                          height="24"
                          viewBox="0 0 24 24"
                          fill="none"
                          stroke="currentColor"
                          stroke-width="2"
                          stroke-linecap="round"
                          stroke-linejoin="round"
                          class="w-5 h-5 text-zinc-400"
                        >
                          <circle cx="11" cy="11" r="8"></circle>
                          <path d="m21 21-4.3-4.3"></path>
                        </svg>
                      </div>
                      <input
                        class="search flex h-[42px] w-full py-2 pl-12 pr-2 rounded-full bg-zinc-100 ring-1 ring-inset ring-zinc-100 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-gray-400 sm:text-sm font-bold uppercase text-base font-mono text-zinc-400"
                        id="token"
                        placeholder="Search for any NFT"
                        type="search"
                        value=""
                        name="token"
                      />
                    </div>
                  </div>
                </div>
              </div>
              <a
                target="_blank"
                rel="noreferrer nofollow"
                href="https://docs.tokenbound.org/"
              >
                <div class="flex space-x-2 border-b cursor-pointer w-fit border-purple text-gradient-purple">
                  <div class="font-sans text-zinc-600 text-sm md:text-base">
                    How to use TBA addresses in your project
                  </div>
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    fill="none"
                    viewBox="0 0 19 14"
                    class="w-4 text-purple"
                  >
                    <path
                      fill="currentColor"
                      d="M17.886 7.61a.864.864 0 0 0 0-1.22L12.389.891a.864.864 0 1 0-1.222 1.222L16.053 7l-4.886 4.886a.864.864 0 0 0 1.222 1.222l5.497-5.497ZM0 7.865h17.275V6.136H0v1.728Z"
                    ></path>
                  </svg>
                </div>
              </a>
            </div>
          </div>
          <div class="md:w-[45%]">
            <video
              autoPlay
              loop
              playsInline
              muted
              src="https://tokenbound.org/homepage/airdrop.mp4"
              class=" rounded-xl "
            ></video>
          </div>
        </div>
      </div> */}

      {/* <div class="mx-auto max-w-[1800px] px-4 sm:px-6 lg:px-24 mt-8">
        <section>
          <div
            class="w-full p-4 mt-16 bg-center bg-cover rounded-xl md:p-12 md:mt-0"
            style={{
              backgroundImage: 'url("https://tokenbound.org/dot-grid.png")',
            }}
            // style='background-image:url("https://tokenbound.org/dot-grid.png")'
          >
            <div class="h-full md:flex">
              <div class="flex flex-col justify-center md:w-1/2">
                <div class="flex flex-col justify-end h-full">
                  <div>
                    <div class="hidden md:block">
                      <div class="text-2xl md:text-3xl font-sans font-semibold">
                        Tokenbound makes it easy to use
                      </div>
                      <div class="text-2xl md:text-3xl font-sans font-semibold">
                        ERC-6551 in your project
                      </div>
                    </div>
                    <div class="md:hidden">
                      <div class="text-2xl md:text-3xl font-sans font-semibold">
                        Tokenbound makes it easy to use ERC-6551 in your project
                      </div>
                    </div>
                    <a
                      target="_blank"
                      rel="noreferrer nofollow"
                      href="https://docs.tokenbound.org"
                    ></a>
                    <div class="flex items-center p-1 pr-4 my-4 mb-12 space-x-4 rounded-full cursor-pointer md:mb-4 w-fit bg-purple/20">
                      <div class="text-sm font-sans font-bold leading-none p-2 rounded-full bg-purple/20 text-purple">
                        NEW
                      </div>
                      <div class="text-sm font-sans font-bold leading-none text-gradient-purple">
                        V2 iframe is now live! Get the SDK
                      </div>
                      <svg
                        xmlns="http://www.w3.org/2000/svg"
                        fill="none"
                        viewBox="0 0 19 14"
                        class="w-4 text-purple"
                      >
                        <path
                          fill="currentColor"
                          d="M17.886 7.61a.864.864 0 0 0 0-1.22L12.389.891a.864.864 0 1 0-1.222 1.222L16.053 7l-4.886 4.886a.864.864 0 0 0 1.222 1.222l5.497-5.497ZM0 7.865h17.275V6.136H0v1.728Z"
                        ></path>
                      </svg>
                    </div>
                  </div>
                </div>
                <div class="flex items-end justify-between w-full h-full">
                  <div class="flex flex-col justify-center p-4 space-y-2 border border-white rounded-lg bg-zinc-50 w-[49%]">
                    <div class="text-xs font-mono uppercase text-gradient-purple">
                      NFTs BROUGHT TO LIFE
                    </div>
                    <div class="font-sans font-semibold text-2xl md:text-4xl lg:text-6xl">
                      62,871
                    </div>
                  </div>
                  <div class="flex flex-col justify-center p-4 space-y-2 border border-white rounded-lg bg-zinc-50 w-[49%]">
                    <div class="text-xs font-mono uppercase text-gradient-purple">
                      evm actions by nfts
                    </div>
                    <div class="font-sans font-semibold text-2xl md:text-4xl lg:text-6xl">
                      1,779
                    </div>
                  </div>
                </div>
              </div>
              <div class="flex-col items-end justify-end hidden w-1/2 md:flex">
                <div class="w-2/3 aspect-square">
                  <iframe
                    class="w-full h-full rounded-xl"
                    src="https://iframe-sapienz.vercel.app/0x26727Ed4f5BA61d3772d1575Bca011Ae3aEF5d36/1/1"
                  ></iframe>
                </div>
              </div>
            </div>
          </div>
        </section>
      </div> */}
    </div>
  );
};

export default Home;
