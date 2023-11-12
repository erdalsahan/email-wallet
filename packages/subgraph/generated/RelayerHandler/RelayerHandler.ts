// THIS IS AN AUTOGENERATED FILE. DO NOT EDIT THIS FILE DIRECTLY.

import {
  ethereum,
  JSONValue,
  TypedMap,
  Entity,
  Bytes,
  Address,
  BigInt
} from "@graphprotocol/graph-ts";

export class AccountCreated extends ethereum.Event {
  get params(): AccountCreated__Params {
    return new AccountCreated__Params(this);
  }
}

export class AccountCreated__Params {
  _event: AccountCreated;

  constructor(event: AccountCreated) {
    this._event = event;
  }

  get emailAddrPointer(): Bytes {
    return this._event.parameters[0].value.toBytes();
  }

  get accountKeyCommit(): Bytes {
    return this._event.parameters[1].value.toBytes();
  }

  get walletSalt(): Bytes {
    return this._event.parameters[2].value.toBytes();
  }

  get psiPoint(): Bytes {
    return this._event.parameters[3].value.toBytes();
  }
}

export class AccountInitialized extends ethereum.Event {
  get params(): AccountInitialized__Params {
    return new AccountInitialized__Params(this);
  }
}

export class AccountInitialized__Params {
  _event: AccountInitialized;

  constructor(event: AccountInitialized) {
    this._event = event;
  }

  get emailAddrPointer(): Bytes {
    return this._event.parameters[0].value.toBytes();
  }

  get accountKeyCommit(): Bytes {
    return this._event.parameters[1].value.toBytes();
  }

  get walletSalt(): Bytes {
    return this._event.parameters[2].value.toBytes();
  }
}

export class AccountTransported extends ethereum.Event {
  get params(): AccountTransported__Params {
    return new AccountTransported__Params(this);
  }
}

export class AccountTransported__Params {
  _event: AccountTransported;

  constructor(event: AccountTransported) {
    this._event = event;
  }

  get oldAccountKeyCommit(): Bytes {
    return this._event.parameters[0].value.toBytes();
  }

  get newEmailAddrPointer(): Bytes {
    return this._event.parameters[1].value.toBytes();
  }

  get newAccountKeyCommit(): Bytes {
    return this._event.parameters[2].value.toBytes();
  }

  get newPSIPoint(): Bytes {
    return this._event.parameters[3].value.toBytes();
  }
}

export class EmailOpHandled extends ethereum.Event {
  get params(): EmailOpHandled__Params {
    return new EmailOpHandled__Params(this);
  }
}

export class EmailOpHandled__Params {
  _event: EmailOpHandled;

  constructor(event: EmailOpHandled) {
    this._event = event;
  }

  get success(): boolean {
    return this._event.parameters[0].value.toBoolean();
  }

  get registeredUnclaimId(): BigInt {
    return this._event.parameters[1].value.toBigInt();
  }

  get emailNullifier(): Bytes {
    return this._event.parameters[2].value.toBytes();
  }

  get emailAddrPointer(): Bytes {
    return this._event.parameters[3].value.toBytes();
  }

  get recipientEmailAddrCommit(): Bytes {
    return this._event.parameters[4].value.toBytes();
  }

  get recipientETHAddr(): Address {
    return this._event.parameters[5].value.toAddress();
  }

  get err(): Bytes {
    return this._event.parameters[6].value.toBytes();
  }
}

export class ExtensionPublished extends ethereum.Event {
  get params(): ExtensionPublished__Params {
    return new ExtensionPublished__Params(this);
  }
}

export class ExtensionPublished__Params {
  _event: ExtensionPublished;

  constructor(event: ExtensionPublished) {
    this._event = event;
  }

  get name(): Bytes {
    return this._event.parameters[0].value.toBytes();
  }

  get extensionAddr(): Address {
    return this._event.parameters[1].value.toAddress();
  }

  get subjectTemplates(): Array<Array<string>> {
    return this._event.parameters[2].value.toStringMatrix();
  }

  get maxExecutionGas(): BigInt {
    return this._event.parameters[3].value.toBigInt();
  }
}

export class RelayerConfigUpdated extends ethereum.Event {
  get params(): RelayerConfigUpdated__Params {
    return new RelayerConfigUpdated__Params(this);
  }
}

export class RelayerConfigUpdated__Params {
  _event: RelayerConfigUpdated;

  constructor(event: RelayerConfigUpdated) {
    this._event = event;
  }

  get addr(): Address {
    return this._event.parameters[0].value.toAddress();
  }

  get hostname(): string {
    return this._event.parameters[1].value.toString();
  }
}

export class RelayerRegistered extends ethereum.Event {
  get params(): RelayerRegistered__Params {
    return new RelayerRegistered__Params(this);
  }
}

export class RelayerRegistered__Params {
  _event: RelayerRegistered;

  constructor(event: RelayerRegistered) {
    this._event = event;
  }

  get addr(): Address {
    return this._event.parameters[0].value.toAddress();
  }

  get randHash(): Bytes {
    return this._event.parameters[1].value.toBytes();
  }

  get emailAddr(): string {
    return this._event.parameters[2].value.toString();
  }

  get hostname(): string {
    return this._event.parameters[3].value.toString();
  }
}

export class UnclaimedFundClaimed extends ethereum.Event {
  get params(): UnclaimedFundClaimed__Params {
    return new UnclaimedFundClaimed__Params(this);
  }
}

export class UnclaimedFundClaimed__Params {
  _event: UnclaimedFundClaimed;

  constructor(event: UnclaimedFundClaimed) {
    this._event = event;
  }

  get id(): BigInt {
    return this._event.parameters[0].value.toBigInt();
  }

  get emailAddrCommit(): Bytes {
    return this._event.parameters[1].value.toBytes();
  }

  get tokenAddr(): Address {
    return this._event.parameters[2].value.toAddress();
  }

  get amount(): BigInt {
    return this._event.parameters[3].value.toBigInt();
  }

  get recipient(): Address {
    return this._event.parameters[4].value.toAddress();
  }
}

export class UnclaimedFundRegistered extends ethereum.Event {
  get params(): UnclaimedFundRegistered__Params {
    return new UnclaimedFundRegistered__Params(this);
  }
}

export class UnclaimedFundRegistered__Params {
  _event: UnclaimedFundRegistered;

  constructor(event: UnclaimedFundRegistered) {
    this._event = event;
  }

  get id(): BigInt {
    return this._event.parameters[0].value.toBigInt();
  }

  get emailAddrCommit(): Bytes {
    return this._event.parameters[1].value.toBytes();
  }

  get tokenAddr(): Address {
    return this._event.parameters[2].value.toAddress();
  }

  get amount(): BigInt {
    return this._event.parameters[3].value.toBigInt();
  }

  get sender(): Address {
    return this._event.parameters[4].value.toAddress();
  }

  get expiryTime(): BigInt {
    return this._event.parameters[5].value.toBigInt();
  }

  get commitmentRandomness(): BigInt {
    return this._event.parameters[6].value.toBigInt();
  }

  get emailAddr(): string {
    return this._event.parameters[7].value.toString();
  }
}

export class UnclaimedFundVoided extends ethereum.Event {
  get params(): UnclaimedFundVoided__Params {
    return new UnclaimedFundVoided__Params(this);
  }
}

export class UnclaimedFundVoided__Params {
  _event: UnclaimedFundVoided;

  constructor(event: UnclaimedFundVoided) {
    this._event = event;
  }

  get id(): BigInt {
    return this._event.parameters[0].value.toBigInt();
  }

  get emailAddrCommit(): Bytes {
    return this._event.parameters[1].value.toBytes();
  }

  get tokenAddr(): Address {
    return this._event.parameters[2].value.toAddress();
  }

  get amount(): BigInt {
    return this._event.parameters[3].value.toBigInt();
  }

  get sender(): Address {
    return this._event.parameters[4].value.toAddress();
  }
}

export class UnclaimedStateClaimed extends ethereum.Event {
  get params(): UnclaimedStateClaimed__Params {
    return new UnclaimedStateClaimed__Params(this);
  }
}

export class UnclaimedStateClaimed__Params {
  _event: UnclaimedStateClaimed;

  constructor(event: UnclaimedStateClaimed) {
    this._event = event;
  }

  get id(): BigInt {
    return this._event.parameters[0].value.toBigInt();
  }

  get emailAddrCommit(): Bytes {
    return this._event.parameters[1].value.toBytes();
  }

  get recipient(): Address {
    return this._event.parameters[2].value.toAddress();
  }
}

export class UnclaimedStateRegistered extends ethereum.Event {
  get params(): UnclaimedStateRegistered__Params {
    return new UnclaimedStateRegistered__Params(this);
  }
}

export class UnclaimedStateRegistered__Params {
  _event: UnclaimedStateRegistered;

  constructor(event: UnclaimedStateRegistered) {
    this._event = event;
  }

  get id(): BigInt {
    return this._event.parameters[0].value.toBigInt();
  }

  get emailAddrCommit(): Bytes {
    return this._event.parameters[1].value.toBytes();
  }

  get extensionAddr(): Address {
    return this._event.parameters[2].value.toAddress();
  }

  get sender(): Address {
    return this._event.parameters[3].value.toAddress();
  }

  get expiryTime(): BigInt {
    return this._event.parameters[4].value.toBigInt();
  }

  get state(): Bytes {
    return this._event.parameters[5].value.toBytes();
  }

  get commitmentRandomness(): BigInt {
    return this._event.parameters[6].value.toBigInt();
  }

  get emailAddr(): string {
    return this._event.parameters[7].value.toString();
  }
}

export class UnclaimedStateVoided extends ethereum.Event {
  get params(): UnclaimedStateVoided__Params {
    return new UnclaimedStateVoided__Params(this);
  }
}

export class UnclaimedStateVoided__Params {
  _event: UnclaimedStateVoided;

  constructor(event: UnclaimedStateVoided) {
    this._event = event;
  }

  get id(): BigInt {
    return this._event.parameters[0].value.toBigInt();
  }

  get emailAddrCommit(): Bytes {
    return this._event.parameters[1].value.toBytes();
  }

  get sender(): Address {
    return this._event.parameters[2].value.toAddress();
  }
}

export class RelayerHandler extends ethereum.SmartContract {
  static bind(address: Address): RelayerHandler {
    return new RelayerHandler("RelayerHandler", address);
  }
}
