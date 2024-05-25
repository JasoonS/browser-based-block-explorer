type transaction = {
  hash: string,
  from: string,
  to: string,
  value: string, // This should be a BigInt and decimals should be a separete field.
  timestamp: string,
}

module TransactionRow = {
  @react.component
  let make = (~tx: transaction, ~rowStyle: string, ~symbol) => {
    <tr className=rowStyle>
      <td className="py-1 px-3 text-left"> {tx.hash->React.string} </td>
      <td className="py-1 px-3 text-left"> {tx.from->React.string} </td>
      <td className="py-1 px-3 text-left"> {tx.to->React.string} </td>
      /// TODO: rather do a base 18 big int conversion here.
      <td className="py-1 px-3 text-left"> {(tx.value ++ symbol)->React.string} </td>
      <td className="py-1 px-3 text-left"> {tx.timestamp->React.string} </td>
    </tr>
  }
}

module Transactions = {
  @react.component
  let make = (~transactions: array<transaction>, ~symbolForAll: option<string>=?) => {
    <table
      className="text-white border rounded border-2 border-primary p-2 m-2 bg-black bg-opacity-30">
      <thead className="m-10 uppercase bg-black">
        <tr>
          <th className="py-3 px-6 text-left"> {"Hash"->React.string} </th>
          <th className="py-3 px-6 text-left"> {"From"->React.string} </th>
          <th className="py-3 px-6 text-left"> {"To"->React.string} </th>
          <th className="py-3 px-6 text-left"> {"Value"->React.string} </th>
          <th className="py-3 px-6 text-left"> {"Timestamp"->React.string} </th>
        </tr>
      </thead>
      <tbody>
        {transactions
        ->Array.mapWithIndex((tx, index) =>
          <TransactionRow
            symbol={symbolForAll->Option.getWithDefault("")}
            key=tx.hash
            tx
            rowStyle={index->Int.mod(2) == 0 ? "bg-white bg-opacity-10" : ""}
          />
        )
        ->React.array}
      </tbody>
    </table>
  }
}

let getBalance = async (client, address) => {
  let balance = await client->Viem.Client.getBalance({"address": address})
  let formattedBalance = balance->Viem.Utilities.Units.formatEther
  formattedBalance
}

let makeClientFromChainId = chainId => {
  let viemChain = chainId->Viem.Chains.fromChainId
  let validChain = switch viemChain {
  | None => Js.Exn.raiseError("Unable to map chainId to viem chain")
  | Some(viemChain) => viemChain
  }
  Viem.Client.createPublicClient({
    "chain": validChain,
    "transport": Viem.Transport.http(),
  })
}

module Overview = {
  @react.component
  let make = (~address: Viem.Address.t) => {
    let url = RescriptReactRouter.useUrl()
    let chainId =
      url.path
      ->List.head
      ->Option.getOr("1")
      ->Int.fromString
      ->Option.getOr(1) // i know, tired
    let client = makeClientFromChainId(chainId)
    let (balance, setBalance) = React.useState(() => "")
    let (ensAddress, setEnsAddress) = React.useState(() => None)

    React.useEffect0(() => {
      client
      ->getBalance(address)
      ->Promise.thenResolve(bal => setBalance(_ => bal->Int.toString))
      ->ignore
      None
    })

    React.useEffect0(() => {
      let _ =
        address
        ->Viem.Address.toString
        ->ENSDataCustomFetch.tryResolveEnsHandleFromAddress
        ->Promise.then(ensAddress => {
          setEnsAddress(_ => Some(ensAddress))
          None->Promise.resolve
        })
      None
    })

    <div className="mb-4 p-4 bg-gray-100 rounded-md">
      <h1 className="text-xl font-bold"> {React.string("Address Overview")} </h1>
      <p>
        <strong> {React.string("Address:")} </strong>
        {address->Viem.Address.toString->React.string}
        <CopyButton textToCopy={address->Viem.Address.toString} />
      </p>
      {switch ensAddress {
      | Some(ensAddress) =>
        <p>
          <strong> {React.string("ENS:")} </strong>
          {ensAddress->React.string}
        </p>
      | None => React.null
      }}
      <p>
        <strong> {React.string("Balance:")} </strong>
        {balance->React.string}
        {" "->React.string}
        {"native token"->React.string}
      </p>
    </div>
  }
}

module InfoTabs = {
  @react.component
  let make = (~chainId, ~address: Viem.Address.t, ~addressSubPage: Routes.addressSubPage) => {
    // Dummy data for overview and transactions
    let transactions: array<transaction> = [
      {hash: "0x1", from: "0x123", to: "0x456", value: "1.0", timestamp: "2024-05-25 12:34:56"},
      {hash: "0x2", from: "0x789", to: "0xabc", value: "2.5", timestamp: "2024-05-24 11:22:33"},
    ]
    let erc20Transfers = [
      {
        hash: "0x3",
        from: "0xdef",
        to: "0xghi",
        value: "1000",
        timestamp: "2024-05-23 10:20:30",
      },
    ]

    let pushSubPage = (newSubPage: Routes.addressSubPage) => {
      let url = Address({chainId, address, addressSubPage: newSubPage})->Routes.pageToUrlString

      url->RescriptReactRouter.push
    }

    <>
      <div className="flex space-x-4 border-b">
        <button
          className={`py-2 px-4 ${addressSubPage === Transactions
              ? "border-b-2 border-blue-500"
              : ""}`}
          onClick={_ => pushSubPage(Transactions)}>
          {React.string("Transactions")}
        </button>
        <button
          className={`py-2 px-4 ${addressSubPage === Routes.Contract
              ? "border-b-2 border-blue-500"
              : ""}`}
          onClick={_ => pushSubPage(Contract)}>
          {React.string("Contract")}
        </button>
        <button
          className={`py-2 px-4 ${addressSubPage === Erc20Transactions
              ? "border-b-2 border-blue-500"
              : ""}`}
          onClick={_ => pushSubPage(Erc20Transactions)}>
          {React.string("ERC20 Transfers")}
        </button>
      </div>
      {switch addressSubPage {
      | Transactions => <Transactions transactions symbolForAll="ETH" />
      | Contract => <Contract chainId address />
      | Erc20Transactions => <Transactions transactions=erc20Transfers />
      | _ => React.null
      }}
    </>
  }
}
@react.component
let make = (~chainId, ~address: Viem.Address.t, ~addressSubPage: Routes.addressSubPage) => {
  <div
    className="flex flex-col items-center justify-center h-screen m-0 p-0 text-primary overflow-y-hidden">
    <div className="mb-4">
      <Overview address />
      <InfoTabs address chainId addressSubPage />
    </div>
  </div>
}
