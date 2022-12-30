contract IO {

    mapping(string => bytes) store;

    bytes constant chars = "!\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~";

    event eventData(string eventData, string signature);

    function write(uint size, uint startKey, uint retLen, string memory sig) public {
        bytes memory states;
        for (uint i = 0; i < size; i++) {
            string memory sK = uintToStr(startKey + i);
            bytes memory val = getVal(startKey + i, retLen);

            if (!compareStrings(string(get(sK)), "")) {
                emit eventData("ioExtended/write/exist", sig);
                return;
            }

            set(sK, getVal(startKey + i, retLen));
            states = abi.encodePacked(states, val);
        }
        emit eventData("storage/write", sig);
    }

    function getVal(uint k, uint retLength) internal pure returns (bytes memory ret) {
        ret = new bytes(retLength);
        for (uint i = 0; i < retLength; i++) {
            ret[i] = chars[(k + i) % chars.length];
        }
        return ret;
    }

    function get(string memory key) public view returns (bytes memory) {
        return store[key];
    }

    function set(string memory key, bytes memory value) public {
        store[key] = value;
    }

    function uintToStr(uint number) internal pure returns (string memory uintAsString) {
        if (number == 0) {
            return "0";
        }
        uint j = number;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory str = new bytes(len);
        uint k = len - 1;
        while (number != 0) {
            str[k--] = byte(uint8(48 + number % 10));
            number /= 10;
        }
        return string(str);
    }

    function scan(uint size, uint startKey, string memory sig) public {
        bytes memory states;
        for (uint i = 0; i < size; i++) {
            string memory sK = uintToStr(startKey + i);
            bytes memory val = get(sK);

            if (compareStrings(string(val), "")) {
                emit eventData("ioExtended/scan/doesntexist", sig);
                return;
            }

            states = abi.encodePacked(states, val);
        }
        emit eventData("storage/scan", sig);
    }

    function revertScan(uint size, uint startKey, string memory sig) public {
        bytes memory states;
        for (uint i = 0; i < size; i++) {
            string memory sK = uintToStr(startKey + size - i - 1);
            bytes memory val = get(sK);

            if (compareStrings(string(val), "")) {
                emit eventData("ioExtended/revertScan/doesntexist", sig);
                return;
            }

            states = abi.encodePacked(states, val);
        }
        emit eventData("storage/revertScan", sig);
    }

    function uintToBytes(uint k) public pure returns (bytes8 b) {
        bytes memory y = new bytes(8);
        assembly {mstore(add(y, 8), k)}
    }

    function getKey(uint k) internal pure returns (bytes32) {
        return uintToBytes(k);
    }

    function compareStrings(string memory a, string memory b) public pure
    returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }

}

// 608060405234801561001057600080fd5b50611694806100206000396000f3fe608060405234801561001057600080fd5b506004361061009a576000357c01000000000000000000000000000000000000000000000000000000009004806394e8767d1161007857806394e8767d146103fe578063bed34bba14610476578063e14d3c14146105e0578063f2e0a6d8146106af5761009a565b80632b29c0fa1461009f578063693ec85e146101f15780637c9da82c14610325575b600080fd5b6101ef600480360360408110156100b557600080fd5b81019080803590602001906401000000008111156100d257600080fd5b8201836020820111156100e457600080fd5b8035906020019184600183028401116401000000008311171561010657600080fd5b91908080601f016020809104026020016040519081016040528093929190818152602001838380828437600081840152601f19601f8201169050808301925050505050505091929192908035906020019064010000000081111561016957600080fd5b82018360208201111561017b57600080fd5b8035906020019184600183028401116401000000008311171561019d57600080fd5b91908080601f016020809104026020016040519081016040528093929190818152602001838380828437600081840152601f19601f82011690508083019250505050505050919291929050505061077e565b005b6102aa6004803603602081101561020757600080fd5b810190808035906020019064010000000081111561022457600080fd5b82018360208201111561023657600080fd5b8035906020019184600183028401116401000000008311171561025857600080fd5b91908080601f016020809104026020016040519081016040528093929190818152602001838380828437600081840152601f19601f820116905080830192505050505050509192919290505050610800565b6040518080602001828103825283818151815260200191508051906020019080838360005b838110156102ea5780820151818401526020810190506102cf565b50505050905090810190601f1680156103175780820380516001836020036101000a031916815260200191505b509250505060405180910390f35b6103fc6004803603608081101561033b57600080fd5b810190808035906020019092919080359060200190929190803590602001909291908035906020019064010000000081111561037657600080fd5b82018360208201111561038857600080fd5b803590602001918460018302840111640100000000831117156103aa57600080fd5b91908080601f016020809104026020016040519081016040528093929190818152602001838380828437600081840152601f19601f82011690508083019250505050505050919291929050505061090b565b005b61042a6004803603602081101561041457600080fd5b8101908080359060200190929190505050610bff565b604051808277ffffffffffffffffffffffffffffffffffffffffffffffff191677ffffffffffffffffffffffffffffffffffffffffffffffff1916815260200191505060405180910390f35b6105c66004803603604081101561048c57600080fd5b81019080803590602001906401000000008111156104a957600080fd5b8201836020820111156104bb57600080fd5b803590602001918460018302840111640100000000831117156104dd57600080fd5b91908080601f016020809104026020016040519081016040528093929190818152602001838380828437600081840152601f19601f8201169050808301925050505050505091929192908035906020019064010000000081111561054057600080fd5b82018360208201111561055257600080fd5b8035906020019184600183028401116401000000008311171561057457600080fd5b91908080601f016020809104026020016040519081016040528093929190818152602001838380828437600081840152601f19601f820116905080830192505050505050509192919290505050610c46565b604051808215151515815260200191505060405180910390f35b6106ad600480360360608110156105f657600080fd5b8101908080359060200190929190803590602001909291908035906020019064010000000081111561062757600080fd5b82018360208201111561063957600080fd5b8035906020019184600183028401116401000000008311171561065b57600080fd5b91908080601f016020809104026020016040519081016040528093929190818152602001838380828437600081840152601f19601f820116905080830192505050505050509192919290505050610d35565b005b61077c600480360360608110156106c557600080fd5b810190808035906020019092919080359060200190929190803590602001906401000000008111156106f657600080fd5b82018360208201111561070857600080fd5b8035906020019184600183028401116401000000008311171561072a57600080fd5b91908080601f016020809104026020016040519081016040528093929190818152602001838380828437600081840152601f19601f820116905080830192505050505050509192919290505050611009565b005b806000836040518082805190602001908083835b602083106107b55780518252602082019150602081019050602083039250610792565b6001836020036101000a038019825116818451168082178552505050505050905001915050908152602001604051809103902090805190602001906107fb92919061153b565b505050565b60606000826040518082805190602001908083835b602083106108385780518252602082019150602081019050602083039250610815565b6001836020036101000a03801982511681845116808217855250505050505090500191505090815260200160405180910390208054600181600116156101000203166002900480601f0160208091040260200160405190810160405280929190818152602001828054600181600116156101000203166002900480156108ff5780601f106108d4576101008083540402835291602001916108ff565b820191906000526020600020905b8154815290600101906020018083116108e257829003601f168201915b50505050509050919050565b606060008090505b85811015610b215760606109288287016112c5565b9050606061093883880187611411565b905061095b61094683610800565b60405180602001604052806000815250610c46565b610a3d577f5baf9aef485ada82a66e0694be5f1e002a90cc1b51031e71350f72a0c7184e0885604051808060200180602001838103835260168152602001807f696f457874656e6465642f77726974652f657869737400000000000000000000815250602001838103825284818151815260200191508051906020019080838360005b838110156109f95780820151818401526020810190506109de565b50505050905090810190601f168015610a265780820380516001836020036101000a031916815260200191505b50935050505060405180910390a150505050610bf9565b610a5282610a4d858a0189611411565b61077e565b83816040516020018083805190602001908083835b60208310610a8a5780518252602082019150602081019050602083039250610a67565b6001836020036101000a03801982511681845116808217855250505050505090500182805190602001908083835b60208310610adb5780518252602082019150602081019050602083039250610ab8565b6001836020036101000a03801982511681845116808217855250505050505090500192505050604051602081830303815290604052935050508080600101915050610913565b507f5baf9aef485ada82a66e0694be5f1e002a90cc1b51031e71350f72a0c7184e08826040518080602001806020018381038352600d8152602001807f73746f726167652f777269746500000000000000000000000000000000000000815250602001838103825284818151815260200191508051906020019080838360005b83811015610bbc578082015181840152602081019050610ba1565b50505050905090810190601f168015610be95780820380516001836020036101000a031916815260200191505b50935050505060405180910390a1505b50505050565b6000606060086040519080825280601f01601f191660200182016040528015610c375781602001600182028038833980820191505090505b50905082600882015250919050565b6000816040516020018082805190602001908083835b60208310610c7f5780518252602082019150602081019050602083039250610c5c565b6001836020036101000a03801982511681845116808217855250505050505090500191505060405160208183030381529060405280519060200120836040516020018082805190602001908083835b60208310610cf15780518252602082019150602081019050602083039250610cce565b6001836020036101000a0380198251168184511680821785525050505050509050019150506040516020818303038152906040528051906020012014905092915050565b606060008090505b84811015610f2c576060610d528286016112c5565b90506060610d5f82610800565b9050610d7a8160405180602001604052806000815250610c46565b15610e5d577f5baf9aef485ada82a66e0694be5f1e002a90cc1b51031e71350f72a0c7184e08856040518080602001806020018381038352601b8152602001807f696f457874656e6465642f7363616e2f646f65736e7465786973740000000000815250602001838103825284818151815260200191508051906020019080838360005b83811015610e19578082015181840152602081019050610dfe565b50505050905090810190601f168015610e465780820380516001836020036101000a031916815260200191505b50935050505060405180910390a150505050611004565b83816040516020018083805190602001908083835b60208310610e955780518252602082019150602081019050602083039250610e72565b6001836020036101000a03801982511681845116808217855250505050505090500182805190602001908083835b60208310610ee65780518252602082019150602081019050602083039250610ec3565b6001836020036101000a03801982511681845116808217855250505050505090500192505050604051602081830303815290604052935050508080600101915050610d3d565b507f5baf9aef485ada82a66e0694be5f1e002a90cc1b51031e71350f72a0c7184e08826040518080602001806020018381038352600c8152602001807f73746f726167652f7363616e0000000000000000000000000000000000000000815250602001838103825284818151815260200191508051906020019080838360005b83811015610fc7578082015181840152602081019050610fac565b50505050905090810190601f168015610ff45780820380516001836020036101000a031916815260200191505b50935050505060405180910390a1505b505050565b606060008090505b848110156111e857606061102b60018388880103036112c5565b9050606061103882610800565b90506110538160405180602001604052806000815250610c46565b15611119577f5baf9aef485ada82a66e0694be5f1e002a90cc1b51031e71350f72a0c7184e08856040518080602001806020018381038352602181526020018061163f60219139604001838103825284818151815260200191508051906020019080838360005b838110156110d55780820151818401526020810190506110ba565b50505050905090810190601f1680156111025780820380516001836020036101000a031916815260200191505b50935050505060405180910390a1505050506112c0565b83816040516020018083805190602001908083835b60208310611151578051825260208201915060208101905060208303925061112e565b6001836020036101000a03801982511681845116808217855250505050505090500182805190602001908083835b602083106111a2578051825260208201915060208101905060208303925061117f565b6001836020036101000a03801982511681845116808217855250505050505090500192505050604051602081830303815290604052935050508080600101915050611011565b507f5baf9aef485ada82a66e0694be5f1e002a90cc1b51031e71350f72a0c7184e0882604051808060200180602001838103835260128152602001807f73746f726167652f7265766572745363616e0000000000000000000000000000815250602001838103825284818151815260200191508051906020019080838360005b83811015611283578082015181840152602081019050611268565b50505050905090810190601f1680156112b05780820380516001836020036101000a031916815260200191505b50935050505060405180910390a1505b505050565b6060600082141561130d576040518060400160405280600181526020017f3000000000000000000000000000000000000000000000000000000000000000815250905061140c565b600082905060005b60008214611337578080600101915050600a828161132f57fe5b049150611315565b6060816040519080825280601f01601f19166020018201604052801561136c5781602001600182028038833980820191505090505b50905060006001830390505b6000861461140457600a868161138a57fe5b066030017f010000000000000000000000000000000000000000000000000000000000000002828280600190039350815181106113c357fe5b60200101907effffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff1916908160001a905350600a86816113fc57fe5b049550611378565b819450505050505b919050565b6060816040519080825280601f01601f1916602001820160405280156114465781602001600182028038833980820191505090505b50905060008090505b82811015611531576040518060800160405280605e81526020016115e1605e91396040518060800160405280605e81526020016115e1605e9139518286018161149457fe5b068151811061149f57fe5b60200101517f010000000000000000000000000000000000000000000000000000000000000090047f0100000000000000000000000000000000000000000000000000000000000000028282815181106114f557fe5b60200101907effffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff1916908160001a905350808060010191505061144f565b5080905092915050565b828054600181600116156101000203166002900490600052602060002090601f016020900481019282601f1061157c57805160ff19168380011785556115aa565b828001600101855582156115aa579182015b828111156115a957825182559160200191906001019061158e565b5b5090506115b791906115bb565b5090565b6115dd91905b808211156115d95760008160009055506001016115c1565b5090565b9056fe2122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f606162636465666768696a6b6c6d6e6f707172737475767778797a7b7c7d7e696f457874656e6465642f7265766572745363616e2f646f65736e746578697374a265627a7a72315820cb220f80072fb68e549777c8eebc660ee194015cf1d358b71c0459884d3b7a6264736f6c634300050c0032

// [{"anonymous":false,"name":"eventData","inputs":[{"indexed":false,"name":"eventData","type":"string","internalType":"string"},{"indexed":false,"name":"signature","type":"string","internalType":"string"}],"type":"event","payable":false},{"constant":true,"name":"compareStrings","inputs":[{"name":"a","type":"string","internalType":"string"},{"name":"b","type":"string","internalType":"string"}],"outputs":[{"name":"","type":"bool","internalType":"bool"}],"type":"function","payable":false,"stateMutability":"pure"},{"constant":true,"name":"get","inputs":[{"name":"key","type":"string","internalType":"string"}],"outputs":[{"name":"","type":"bytes","internalType":"bytes"}],"type":"function","payable":false,"stateMutability":"view"},{"constant":false,"name":"revertScan","inputs":[{"name":"size","type":"uint256","internalType":"uint256"},{"name":"startKey","type":"uint256","internalType":"uint256"},{"name":"sig","type":"string","internalType":"string"}],"outputs":[],"type":"function","payable":false,"stateMutability":"nonpayable"},{"constant":false,"name":"scan","inputs":[{"name":"size","type":"uint256","internalType":"uint256"},{"name":"startKey","type":"uint256","internalType":"uint256"},{"name":"sig","type":"string","internalType":"string"}],"outputs":[],"type":"function","payable":false,"stateMutability":"nonpayable"},{"constant":false,"name":"set","inputs":[{"name":"key","type":"string","internalType":"string"},{"name":"value","type":"bytes","internalType":"bytes"}],"outputs":[],"type":"function","payable":false,"stateMutability":"nonpayable"},{"constant":true,"name":"uintToBytes","inputs":[{"name":"k","type":"uint256","internalType":"uint256"}],"outputs":[{"name":"b","type":"bytes8","internalType":"bytes8"}],"type":"function","payable":false,"stateMutability":"pure"},{"constant":false,"name":"write","inputs":[{"name":"size","type":"uint256","internalType":"uint256"},{"name":"startKey","type":"uint256","internalType":"uint256"},{"name":"retLen","type":"uint256","internalType":"uint256"},{"name":"sig","type":"string","internalType":"string"}],"outputs":[],"type":"function","payable":false,"stateMutability":"nonpayable"}]