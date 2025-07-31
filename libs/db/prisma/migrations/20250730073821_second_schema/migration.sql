/*
  Warnings:

  - You are about to drop the `ACTION_LOG` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `CHIP_LEDGER` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `COMMUNITY_CARD` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `HAND` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `HAND_PLAYER` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `PLAYER` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `POT` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `POT_AWARD` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `TABLE` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `TABLE_PLAYER` table. If the table is not empty, all the data it contains will be lost.

*/
-- CreateEnum
CREATE TYPE "public"."PlayerStatus" AS ENUM ('active', 'banned', 'suspended');

-- CreateEnum
CREATE TYPE "public"."ChipLedgerType" AS ENUM ('buyin', 'win', 'rake', 'refund', 'deposit', 'withdraw');

-- CreateEnum
CREATE TYPE "public"."TableType" AS ENUM ('cash', 'tournament');

-- CreateEnum
CREATE TYPE "public"."TableStatus" AS ENUM ('waiting', 'running', 'ended');

-- CreateEnum
CREATE TYPE "public"."HandStage" AS ENUM ('preflop', 'flop', 'turn', 'river', 'showdown', 'complete');

-- CreateEnum
CREATE TYPE "public"."HandPlayerStatus" AS ENUM ('in', 'folded', 'all_in', 'out');

-- CreateEnum
CREATE TYPE "public"."CommunityCardStage" AS ENUM ('flop', 'turn', 'river');

-- CreateEnum
CREATE TYPE "public"."ActionType" AS ENUM ('check', 'call', 'fold', 'bet', 'raise', 'all_in', 'post_small_blind', 'post_big_blind');

-- DropForeignKey
ALTER TABLE "public"."ACTION_LOG" DROP CONSTRAINT "ACTION_LOG_hand_id_fkey";

-- DropForeignKey
ALTER TABLE "public"."ACTION_LOG" DROP CONSTRAINT "ACTION_LOG_hand_player_id_fkey";

-- DropForeignKey
ALTER TABLE "public"."CHIP_LEDGER" DROP CONSTRAINT "CHIP_LEDGER_player_id_fkey";

-- DropForeignKey
ALTER TABLE "public"."CHIP_LEDGER" DROP CONSTRAINT "CHIP_LEDGER_related_hand_id_fkey";

-- DropForeignKey
ALTER TABLE "public"."CHIP_LEDGER" DROP CONSTRAINT "CHIP_LEDGER_related_table_id_fkey";

-- DropForeignKey
ALTER TABLE "public"."COMMUNITY_CARD" DROP CONSTRAINT "COMMUNITY_CARD_hand_id_fkey";

-- DropForeignKey
ALTER TABLE "public"."HAND" DROP CONSTRAINT "HAND_table_id_fkey";

-- DropForeignKey
ALTER TABLE "public"."HAND" DROP CONSTRAINT "HAND_winning_player_id_fkey";

-- DropForeignKey
ALTER TABLE "public"."HAND_PLAYER" DROP CONSTRAINT "HAND_PLAYER_hand_id_fkey";

-- DropForeignKey
ALTER TABLE "public"."HAND_PLAYER" DROP CONSTRAINT "HAND_PLAYER_player_id_fkey";

-- DropForeignKey
ALTER TABLE "public"."POT" DROP CONSTRAINT "POT_hand_id_fkey";

-- DropForeignKey
ALTER TABLE "public"."POT_AWARD" DROP CONSTRAINT "POT_AWARD_player_id_fkey";

-- DropForeignKey
ALTER TABLE "public"."POT_AWARD" DROP CONSTRAINT "POT_AWARD_pot_id_fkey";

-- DropForeignKey
ALTER TABLE "public"."TABLE_PLAYER" DROP CONSTRAINT "TABLE_PLAYER_player_id_fkey";

-- DropForeignKey
ALTER TABLE "public"."TABLE_PLAYER" DROP CONSTRAINT "TABLE_PLAYER_table_id_fkey";

-- DropTable
DROP TABLE "public"."ACTION_LOG";

-- DropTable
DROP TABLE "public"."CHIP_LEDGER";

-- DropTable
DROP TABLE "public"."COMMUNITY_CARD";

-- DropTable
DROP TABLE "public"."HAND";

-- DropTable
DROP TABLE "public"."HAND_PLAYER";

-- DropTable
DROP TABLE "public"."PLAYER";

-- DropTable
DROP TABLE "public"."POT";

-- DropTable
DROP TABLE "public"."POT_AWARD";

-- DropTable
DROP TABLE "public"."TABLE";

-- DropTable
DROP TABLE "public"."TABLE_PLAYER";

-- DropEnum
DROP TYPE "public"."ACTION_TYPE";

-- DropEnum
DROP TYPE "public"."CHIP_LEDGER_TYPE";

-- DropEnum
DROP TYPE "public"."COMMUNITY_CARD_STAGE";

-- DropEnum
DROP TYPE "public"."HAND_PLAYER_STATUS";

-- DropEnum
DROP TYPE "public"."HAND_STAGE";

-- DropEnum
DROP TYPE "public"."PLAYER_STATUS";

-- DropEnum
DROP TYPE "public"."TABLE_STATUS";

-- DropEnum
DROP TYPE "public"."TABLE_TYPE";

-- CreateTable
CREATE TABLE "public"."Player" (
    "playerId" SERIAL NOT NULL,
    "playerName" VARCHAR(255) NOT NULL,
    "email" TEXT NOT NULL,
    "passwordHash" VARCHAR(255) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "lastLoginAt" TIMESTAMP(3) NOT NULL,
    "status" "public"."PlayerStatus" NOT NULL DEFAULT 'active',

    CONSTRAINT "Player_pkey" PRIMARY KEY ("playerId")
);

-- CreateTable
CREATE TABLE "public"."ChipLedger" (
    "ledgerId" SERIAL NOT NULL,
    "playerId" INTEGER NOT NULL,
    "relatedTableId" INTEGER,
    "relatedHandId" INTEGER,
    "type" "public"."ChipLedgerType" NOT NULL,
    "amount" INTEGER NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ChipLedger_pkey" PRIMARY KEY ("ledgerId")
);

-- CreateTable
CREATE TABLE "public"."Table" (
    "tableId" SERIAL NOT NULL,
    "name" VARCHAR(255),
    "type" "public"."TableType" NOT NULL,
    "status" "public"."TableStatus" NOT NULL,
    "buyinMin" INTEGER NOT NULL,
    "buyinMax" INTEGER NOT NULL,
    "seatsCount" INTEGER NOT NULL,
    "smallBlind" INTEGER NOT NULL,
    "bigBlind" INTEGER NOT NULL,
    "ante" INTEGER NOT NULL DEFAULT 0,
    "maxRaiseMultiplier" INTEGER NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Table_pkey" PRIMARY KEY ("tableId")
);

-- CreateTable
CREATE TABLE "public"."TablePlayer" (
    "tablePlayerId" SERIAL NOT NULL,
    "tableId" INTEGER NOT NULL,
    "playerId" INTEGER NOT NULL,
    "seatNumber" INTEGER NOT NULL,
    "joinAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "buyinAmount" INTEGER NOT NULL,
    "currentStack" INTEGER NOT NULL,
    "isActive" BOOLEAN NOT NULL,
    "hasFolded" BOOLEAN NOT NULL,
    "isAllIn" BOOLEAN NOT NULL,

    CONSTRAINT "TablePlayer_pkey" PRIMARY KEY ("tablePlayerId")
);

-- CreateTable
CREATE TABLE "public"."Hand" (
    "handId" SERIAL NOT NULL,
    "tableId" INTEGER NOT NULL,
    "dealerSeat" INTEGER NOT NULL,
    "smallBlindSeat" INTEGER NOT NULL,
    "bigBlindSeat" INTEGER NOT NULL,
    "stage" "public"."HandStage" NOT NULL,
    "deckOrder" JSONB NOT NULL,
    "potAmount" INTEGER NOT NULL,
    "rakeAmount" INTEGER NOT NULL,
    "winningPlayerId" INTEGER,
    "winningHandDesc" VARCHAR(255),
    "startedAt" TIMESTAMP(3) NOT NULL,
    "endedAt" TIMESTAMP(3),

    CONSTRAINT "Hand_pkey" PRIMARY KEY ("handId")
);

-- CreateTable
CREATE TABLE "public"."HandPlayer" (
    "handPlayerId" SERIAL NOT NULL,
    "handId" INTEGER NOT NULL,
    "playerId" INTEGER NOT NULL,
    "seatNumber" INTEGER NOT NULL,
    "holeCards" TEXT[],
    "startingStack" INTEGER NOT NULL,
    "endingStack" INTEGER NOT NULL,
    "status" "public"."HandPlayerStatus" NOT NULL,

    CONSTRAINT "HandPlayer_pkey" PRIMARY KEY ("handPlayerId")
);

-- CreateTable
CREATE TABLE "public"."CommunityCard" (
    "communityCardId" SERIAL NOT NULL,
    "handId" INTEGER NOT NULL,
    "stage" "public"."CommunityCardStage" NOT NULL,
    "cardPosition" INTEGER NOT NULL,
    "cardCode" VARCHAR(2) NOT NULL,

    CONSTRAINT "CommunityCard_pkey" PRIMARY KEY ("communityCardId")
);

-- CreateTable
CREATE TABLE "public"."ActionLog" (
    "actionLogId" SERIAL NOT NULL,
    "handId" INTEGER NOT NULL,
    "handPlayerId" INTEGER NOT NULL,
    "actionTs" TIMESTAMP(3) NOT NULL,
    "actionType" "public"."ActionType" NOT NULL,
    "amount" INTEGER NOT NULL,
    "totalBetThisRound" INTEGER NOT NULL,
    "resultingStack" INTEGER NOT NULL,

    CONSTRAINT "ActionLog_pkey" PRIMARY KEY ("actionLogId")
);

-- CreateTable
CREATE TABLE "public"."Pot" (
    "potId" SERIAL NOT NULL,
    "handId" INTEGER NOT NULL,
    "amount" INTEGER NOT NULL,
    "isMain" BOOLEAN NOT NULL,

    CONSTRAINT "Pot_pkey" PRIMARY KEY ("potId")
);

-- CreateTable
CREATE TABLE "public"."PotAward" (
    "potAwardId" SERIAL NOT NULL,
    "potId" INTEGER NOT NULL,
    "playerId" INTEGER NOT NULL,
    "awardAmount" INTEGER NOT NULL,

    CONSTRAINT "PotAward_pkey" PRIMARY KEY ("potAwardId")
);

-- CreateIndex
CREATE UNIQUE INDEX "Player_email_key" ON "public"."Player"("email");

-- CreateIndex
CREATE UNIQUE INDEX "TablePlayer_tableId_seatNumber_key" ON "public"."TablePlayer"("tableId", "seatNumber");

-- CreateIndex
CREATE UNIQUE INDEX "HandPlayer_handId_seatNumber_key" ON "public"."HandPlayer"("handId", "seatNumber");

-- CreateIndex
CREATE UNIQUE INDEX "CommunityCard_handId_cardPosition_key" ON "public"."CommunityCard"("handId", "cardPosition");

-- AddForeignKey
ALTER TABLE "public"."ChipLedger" ADD CONSTRAINT "ChipLedger_playerId_fkey" FOREIGN KEY ("playerId") REFERENCES "public"."Player"("playerId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."ChipLedger" ADD CONSTRAINT "ChipLedger_relatedTableId_fkey" FOREIGN KEY ("relatedTableId") REFERENCES "public"."Table"("tableId") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."ChipLedger" ADD CONSTRAINT "ChipLedger_relatedHandId_fkey" FOREIGN KEY ("relatedHandId") REFERENCES "public"."Hand"("handId") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."TablePlayer" ADD CONSTRAINT "TablePlayer_tableId_fkey" FOREIGN KEY ("tableId") REFERENCES "public"."Table"("tableId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."TablePlayer" ADD CONSTRAINT "TablePlayer_playerId_fkey" FOREIGN KEY ("playerId") REFERENCES "public"."Player"("playerId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."Hand" ADD CONSTRAINT "Hand_tableId_fkey" FOREIGN KEY ("tableId") REFERENCES "public"."Table"("tableId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."Hand" ADD CONSTRAINT "Hand_winningPlayerId_fkey" FOREIGN KEY ("winningPlayerId") REFERENCES "public"."Player"("playerId") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."HandPlayer" ADD CONSTRAINT "HandPlayer_handId_fkey" FOREIGN KEY ("handId") REFERENCES "public"."Hand"("handId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."HandPlayer" ADD CONSTRAINT "HandPlayer_playerId_fkey" FOREIGN KEY ("playerId") REFERENCES "public"."Player"("playerId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."CommunityCard" ADD CONSTRAINT "CommunityCard_handId_fkey" FOREIGN KEY ("handId") REFERENCES "public"."Hand"("handId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."ActionLog" ADD CONSTRAINT "ActionLog_handId_fkey" FOREIGN KEY ("handId") REFERENCES "public"."Hand"("handId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."ActionLog" ADD CONSTRAINT "ActionLog_handPlayerId_fkey" FOREIGN KEY ("handPlayerId") REFERENCES "public"."HandPlayer"("handPlayerId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."Pot" ADD CONSTRAINT "Pot_handId_fkey" FOREIGN KEY ("handId") REFERENCES "public"."Hand"("handId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."PotAward" ADD CONSTRAINT "PotAward_potId_fkey" FOREIGN KEY ("potId") REFERENCES "public"."Pot"("potId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."PotAward" ADD CONSTRAINT "PotAward_playerId_fkey" FOREIGN KEY ("playerId") REFERENCES "public"."Player"("playerId") ON DELETE CASCADE ON UPDATE CASCADE;
