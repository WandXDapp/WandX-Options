# Who is Writer?
Any willing person who wants to launch the financial derivates over the blockchain can be
writer. It means writer is obliged to buy (American Put Option) or sell (American Call Option)
from the seller (American Put Option) or buyer (American Call Option).  

# How writer can interact with the smart contracts?
Writer can directly communicate with the `DerivativeFactory` contract to create the Option.
writer only need to pay certain amount of fee as the service charge to introduce the option on the blockchain,
This fee will be paid to the host of the dApp (For WandX dApp it will credited to WandX organisation or it can be any other
organisation which host the dApp and using the WandX-Option protocol).  

__createOption__ It is the function writer can use to launch the option by putting up certain parameters  

`_baseToken`: Address of the ERC20 token which will act as underlying securities.  
`_quoteToken`: Address of the ERC20 token which will be provided as the premium to hold the option.   
`_strikePrice`: Price at which buyer will obligate to buy the base token.  
`_blockTimestamp`: Unix timestamp to expire the option

