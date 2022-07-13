# Constant-Product-Automated-Market-Maker-CPAMM

###     What are Automated Market Maker ?
```
1) An automated market maker (AMM) is a type of decentralized exchange (DEX)    protocol that relies on a mathematical formula to price assets. 
2) Instead of using an order book like a traditional exchange, assets are priced according to a pricing algorithm
```

### Types of AMM based on formulas :
```
1) Constant Sum Market Makers
2) Constant Product Market Makers
3) Constant Mean Market Makers
4) Hybrid Function Market Makers
5) Dynamic Automated Market Makers
... many more
```

### Features of AMM:
```
1) Availability of tokens for trading
2) Quick to execute
3) No third party
4) Better experience for users
```

Here we will talk aboout **Constant Product Market Maker**

### Formula for swapping :
```
x * y = k
where,
x = token0 amount
y = token1 amount
k =Constant to be  maintained
```
While swapping tokens , the ratios of both tokens is maintained using constant k.

### Formula for Adding/Removing Liquidity :
```
(x / y) = ( dx / dy)

where,
x = token0 amount
y = token1 amoun
dx =new token0 amountIn/amountOut
dy =new token1 amountIn/amountOut
```

Price of tokens should remain same while adding/removing liquidity or else any user can add/remove shares to disrupt the prices in the contract.

### Formula to mint/burn shares
```
f(x, y) = value of liquidity
We will define f(x, y) = sqrt(xy)

(L1 - L0) / L0 = dx / x = dy / y

where,
L0 = f(x, y)
L1 = f(x + dx, y + dy)
T = total shares
s = shares to mint

Total shares should increase proportional to increase in liquidity
s = (L1 - L0) * T / L0 
```

### Mathematical Explanation for all formulas :
```
Link1
Link2
Link3
```


# General Explanation :

- For users to swap tokens **automatically & quickly**, contract must have liquidity for those tokens all the time
- For this purpose **Liquidity Providers** stake their tokens in return they get some amount of reward from transaction fees & swapping.
- Liquidity Providers get **shares** for the amount of stake they put .
- Users can **swap** tokens & get respective token back using the above formula.
- Key members here are :
- - Liquidity Providers
-  - Traders for swapping

# Code Explanation :

```
IERC20 public immutable token0;
```
IERC20 interface is used to create multiple tokens.

```
uint public reserve0;
```
State variable reserve used to track the amount for each token.

```
uint public totalSupply;
```
State variable reserve used to track for total share supply.

```
mapping(address => uint) public balanceOf;
```
Keeping track of shares for each Liquidity provider for security purpose.

```
constructor(address _token0, address _token1)
```
Need to supply address of collateral tokens while deploying contract.

```
function _mint(address _to,uint _amount)
```
Internal function used to mint the shares for any user who has kept tokens as collateral.

```
function _burn(address _from,uint _amount)
```
Internal function used to burn shares while liquidity provider wants to retrive tokes in exchange for shares provided.

```
function _update(uint _reserve0,uint _reserve1)
```
Internal function used to update the reserves for both coins.

```
function swap(address _tokenIn,uint _amountIn)
```
External function used by any user to exchange token for amount in return.
return amount is calculated by formula mentioned in above comments.

```
function addLiquidity(uint _amount0,uint _amount1)
```
External function used by liquidity providers to add tokens into this contract.
In return no. of worth shares minted for them according to the formula mentioned above.

```
function removeLiquidity(uint _shares)
```
External funciton used by liquidity providers to get tokens back in exchange for no of shares.

## Disadvantages of CPAMM -
- High Volatility
- High chances of arbitrageurs intervention
- Possibility of impermanent loss or gain ( **Impermanent loss** is a net difference between the value of two cryptocurrency assets in a liquidity pool-based automated market maker )

## Updates :
- Exceptions has to be added
