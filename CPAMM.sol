pragma solidity ^0.8.0;

import "./IERC20.sol";

contract CPAMMA {

    // Create 2 Tokens
    IERC20 public immutable token0;
    IERC20 public immutable token1;

    // to keep track of both token counts
    uint public reserve0;
    uint public reserve1;

    // to keep track of shares
    uint public totalSupply;
    // to keep track of shares per user
    mapping(address => uint) public balanceOf;
    

    //create constructor
    constructor(address _token0,address _token1){
        token0 =IERC20(_token0);
        token1 =IERC20(_token1);
    }

    // to mint shares
    function _mint(address _to,uint _amount) private {
        balanceOf[_to] += _amount; // add shares to user
        totalSupply +=_amount; // increase total supply
    }

    // to burn shares
    function _burn(address _from,uint _amount) private {
        balanceOf[_from] -= _amount; // remove shares to user
        totalSupply -=_amount; // decrease total supply
    }
    
    // to update reserve
    function _update(uint _reserve0,uint _reserve1) private {
        reserve0 =_reserve0;
        reserve1 =_reserve1;
    }

    //Functions for user
    //1. Swap tokens
    //2. add liquidity
    //3. remove liquidity

    // here tokenIn can be any of 2 token , so need to check it before calc. token out
    function swap(address _tokenIn,uint _amountIn) external returns(uint amountOut) {
        require(_tokenIn == address(token0) || _tokenIn == address(token1),"invalid token");
        require(_amountIn > 0 ,"amount is 0");

        // pull in amountIn
        bool isToken0 = _tokenIn == address(token0);
        (IERC20 tokenIn,IERC20 tokenOut,uint reserveIn ,uint reserveOut) = isToken0 ? (token0,token1,reserve0,reserve1) : (token1,token0,reserve1,reserve0); // if true tokenIn is 0 else 1.
        tokenIn.transferFrom(msg.sender,address(this),_amountIn);
        // calc amountOut including fees 0.3%
        // y*dx/x+dx =dy
        uint amountInwithFee =(_amountIn * 997)/1000; // sol doesnt allow float
        amountOut = (reserveOut*amountInwithFee)/(reserveIn + amountInwithFee);
        // return amountOut
        tokenOut.transfer(msg.sender,amountOut);
        // update reserve
        _update(
            token0.balanceOf(address(this)),
            token1.balanceOf(address(this))
        );
    }

    function _sqrt(uint y) private pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    function addLiquidity(uint _amount0,uint _amount1) external returns(uint shares) {
        // pull in token0 & token1
        token0.transferFrom(msg.sender,address(this),_amount0);
        token1.transferFrom(msg.sender,address(this),_amount1);
        
        // dy/dx =y/x -- to maintaine the same price
        if (_amount0>0 || _amount1>0){
            require(reserve0*_amount1 == reserve1*_amount0, "constraint not satisfied");
        }

        // mint shares
        // total liq = sqrt(x,y)
        // s = T(dx/y) = T(dy/y)
        if (totalSupply==0){
            shares = _sqrt(_amount0*_amount1);
        }else{
            shares =_min(
                (_amount0*totalSupply)/reserve1,
                (_amount1*totalSupply)/reserve0
            );
        }
        
        require(shares>0 ,"shares =0");
        _mint(msg.sender,shares);

        // update reserves
        _update(
            token0.balanceOf(address(this)),
            token1.balanceOf(address(this))
        );

    }

    function _min(uint x,uint y) private pure returns(uint) {
        return x <= y ? x : y;
    }

    function removeLiquidity(uint _shares) external returns(uint amount0,uint amount1) {
        // calc amount0 & amount1 to return user
        // dx = s/T * x
        uint bal0 = token0.balanceOf(address(this));
        uint bal1 = token1.balanceOf(address(this));
        amount0 =(_shares * bal0)/totalSupply;
        amount1 =(_shares * bal1)/totalSupply;

        require(amount0 >0 && amount1 >0 , "any amount is 0");

        // burn shares
        _burn(msg.sender,_shares);
        // update reserves
        _update(bal0 - amount0,
                bal1 - amount1);
        // return tokens back
        token0.transfer(msg.sender,amount0);
        token1.transfer(msg.sender,amount1);
    }

}