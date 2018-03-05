// Returns the time of the last mined block in seconds
export function latestTime () {
    return web3.eth.getBlock('latest').timestamp;
  }

export function latestBlock () {
    return web3.eth.getBlock('latest').number;
}

export default { latestTime, latestBlock };