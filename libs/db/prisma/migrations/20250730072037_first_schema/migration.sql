/*
  Warnings:

  - You are about to drop the `Player` table. If the table is not empty, all the data it contains will be lost.

*/
-- CreateEnum
CREATE TYPE "public"."PLAYER_STATUS" AS ENUM ('active', 'banned', 'suspended');

-- CreateEnum
CREATE TYPE "public"."CHIP_LEDGER_TYPE" AS ENUM ('buyin', 'win', 'rake', 'refund', 'deposit', 'withdraw');

-- CreateEnum
CREATE TYPE "public"."TABLE_TYPE" AS ENUM ('cash', 'tournament');

-- CreateEnum
CREATE TYPE "public"."TABLE_STATUS" AS ENUM ('waiting', 'running', 'ended');

-- CreateEnum
CREATE TYPE "public"."HAND_STAGE" AS ENUM ('preflop', 'flop', 'turn', 'river', 'showdown', 'complete');

-- CreateEnum
CREATE TYPE "public"."HAND_PLAYER_STATUS" AS ENUM ('in', 'folded', 'all_in', 'out');

-- CreateEnum
CREATE TYPE "public"."COMMUNITY_CARD_STAGE" AS ENUM ('flop', 'turn', 'river');

-- CreateEnum
CREATE TYPE "public"."ACTION_TYPE" AS ENUM ('check', 'call', 'fold', 'bet', 'raise', 'all_in', 'post_small_blind', 'post_big_blind');

-- DropTable
DROP TABLE "public"."Player";

-- CreateTable
CREATE TABLE "public"."PLAYER" (
    "player_id" SERIAL NOT NULL,
    "player_name" VARCHAR(255) NOT NULL,
    "email" TEXT NOT NULL,
    "password_hash" VARCHAR(255) NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "last_login_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "status" "public"."PLAYER_STATUS" NOT NULL DEFAULT 'active',

    CONSTRAINT "PLAYER_pkey" PRIMARY KEY ("player_id")
);

-- CreateTable
CREATE TABLE "public"."CHIP_LEDGER" (
    "ledger_id" SERIAL NOT NULL,
    "player_id" INTEGER NOT NULL,
    "related_table_id" INTEGER,
    "related_hand_id" INTEGER,
    "type" "public"."CHIP_LEDGER_TYPE" NOT NULL,
    "amount" INTEGER NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "CHIP_LEDGER_pkey" PRIMARY KEY ("ledger_id")
);

-- CreateTable
CREATE TABLE "public"."TABLE" (
    "table_id" SERIAL NOT NULL,
    "name" VARCHAR(255),
    "type" "public"."TABLE_TYPE" NOT NULL,
    "status" "public"."TABLE_STATUS" NOT NULL,
    "buyin_min" INTEGER NOT NULL,
    "buyin_max" INTEGER NOT NULL,
    "seats_count" INTEGER NOT NULL,
    "small_blind" INTEGER NOT NULL,
    "big_blind" INTEGER NOT NULL,
    "ante" INTEGER NOT NULL DEFAULT 0,
    "max_raise_multiplier" INTEGER NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "TABLE_pkey" PRIMARY KEY ("table_id")
);

-- CreateTable
CREATE TABLE "public"."TABLE_PLAYER" (
    "table_player_id" SERIAL NOT NULL,
    "table_id" INTEGER NOT NULL,
    "player_id" INTEGER NOT NULL,
    "seat_number" INTEGER NOT NULL,
    "join_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "buyin_amount" INTEGER NOT NULL,
    "current_stack" INTEGER NOT NULL,
    "is_active" BOOLEAN NOT NULL,
    "has_folded" BOOLEAN NOT NULL,
    "is_all_in" BOOLEAN NOT NULL,

    CONSTRAINT "TABLE_PLAYER_pkey" PRIMARY KEY ("table_player_id")
);

-- CreateTable
CREATE TABLE "public"."HAND" (
    "hand_id" SERIAL NOT NULL,
    "table_id" INTEGER NOT NULL,
    "dealer_seat" INTEGER NOT NULL,
    "small_blind_seat" INTEGER NOT NULL,
    "big_blind_seat" INTEGER NOT NULL,
    "stage" "public"."HAND_STAGE" NOT NULL,
    "deck_order" JSONB NOT NULL,
    "pot_amount" INTEGER NOT NULL,
    "rake_amount" INTEGER NOT NULL,
    "winning_player_id" INTEGER,
    "winning_hand_desc" VARCHAR(255),
    "started_at" TIMESTAMP(3) NOT NULL,
    "ended_at" TIMESTAMP(3),

    CONSTRAINT "HAND_pkey" PRIMARY KEY ("hand_id")
);

-- CreateTable
CREATE TABLE "public"."HAND_PLAYER" (
    "hand_player_id" SERIAL NOT NULL,
    "hand_id" INTEGER NOT NULL,
    "player_id" INTEGER NOT NULL,
    "seat_number" INTEGER NOT NULL,
    "hole_cards" VARCHAR(2)[],
    "starting_stack" INTEGER NOT NULL,
    "ending_stack" INTEGER NOT NULL,
    "status" "public"."HAND_PLAYER_STATUS" NOT NULL,

    CONSTRAINT "HAND_PLAYER_pkey" PRIMARY KEY ("hand_player_id")
);

-- CreateTable
CREATE TABLE "public"."COMMUNITY_CARD" (
    "community_card_id" SERIAL NOT NULL,
    "hand_id" INTEGER NOT NULL,
    "stage" "public"."COMMUNITY_CARD_STAGE" NOT NULL,
    "card_position" INTEGER NOT NULL,
    "card_code" VARCHAR(2) NOT NULL,

    CONSTRAINT "COMMUNITY_CARD_pkey" PRIMARY KEY ("community_card_id")
);

-- CreateTable
CREATE TABLE "public"."ACTION_LOG" (
    "action_log_id" SERIAL NOT NULL,
    "hand_id" INTEGER NOT NULL,
    "hand_player_id" INTEGER NOT NULL,
    "action_ts" TIMESTAMP(3) NOT NULL,
    "action_type" "public"."ACTION_TYPE" NOT NULL,
    "amount" INTEGER NOT NULL,
    "total_bet_this_round" INTEGER NOT NULL,
    "resulting_stack" INTEGER NOT NULL,

    CONSTRAINT "ACTION_LOG_pkey" PRIMARY KEY ("action_log_id")
);

-- CreateTable
CREATE TABLE "public"."POT" (
    "pot_id" SERIAL NOT NULL,
    "hand_id" INTEGER NOT NULL,
    "amount" INTEGER NOT NULL,
    "is_main" BOOLEAN NOT NULL,

    CONSTRAINT "POT_pkey" PRIMARY KEY ("pot_id")
);

-- CreateTable
CREATE TABLE "public"."POT_AWARD" (
    "pot_award_id" SERIAL NOT NULL,
    "pot_id" INTEGER NOT NULL,
    "player_id" INTEGER NOT NULL,
    "award_amount" INTEGER NOT NULL,

    CONSTRAINT "POT_AWARD_pkey" PRIMARY KEY ("pot_award_id")
);

-- CreateIndex
CREATE UNIQUE INDEX "PLAYER_email_key" ON "public"."PLAYER"("email");

-- CreateIndex
CREATE UNIQUE INDEX "TABLE_PLAYER_table_id_seat_number_key" ON "public"."TABLE_PLAYER"("table_id", "seat_number");

-- CreateIndex
CREATE UNIQUE INDEX "HAND_PLAYER_hand_id_seat_number_key" ON "public"."HAND_PLAYER"("hand_id", "seat_number");

-- CreateIndex
CREATE UNIQUE INDEX "COMMUNITY_CARD_hand_id_card_position_key" ON "public"."COMMUNITY_CARD"("hand_id", "card_position");

-- AddForeignKey
ALTER TABLE "public"."CHIP_LEDGER" ADD CONSTRAINT "CHIP_LEDGER_player_id_fkey" FOREIGN KEY ("player_id") REFERENCES "public"."PLAYER"("player_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."CHIP_LEDGER" ADD CONSTRAINT "CHIP_LEDGER_related_table_id_fkey" FOREIGN KEY ("related_table_id") REFERENCES "public"."TABLE"("table_id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."CHIP_LEDGER" ADD CONSTRAINT "CHIP_LEDGER_related_hand_id_fkey" FOREIGN KEY ("related_hand_id") REFERENCES "public"."HAND"("hand_id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."TABLE_PLAYER" ADD CONSTRAINT "TABLE_PLAYER_table_id_fkey" FOREIGN KEY ("table_id") REFERENCES "public"."TABLE"("table_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."TABLE_PLAYER" ADD CONSTRAINT "TABLE_PLAYER_player_id_fkey" FOREIGN KEY ("player_id") REFERENCES "public"."PLAYER"("player_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."HAND" ADD CONSTRAINT "HAND_table_id_fkey" FOREIGN KEY ("table_id") REFERENCES "public"."TABLE"("table_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."HAND" ADD CONSTRAINT "HAND_winning_player_id_fkey" FOREIGN KEY ("winning_player_id") REFERENCES "public"."PLAYER"("player_id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."HAND_PLAYER" ADD CONSTRAINT "HAND_PLAYER_hand_id_fkey" FOREIGN KEY ("hand_id") REFERENCES "public"."HAND"("hand_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."HAND_PLAYER" ADD CONSTRAINT "HAND_PLAYER_player_id_fkey" FOREIGN KEY ("player_id") REFERENCES "public"."PLAYER"("player_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."COMMUNITY_CARD" ADD CONSTRAINT "COMMUNITY_CARD_hand_id_fkey" FOREIGN KEY ("hand_id") REFERENCES "public"."HAND"("hand_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."ACTION_LOG" ADD CONSTRAINT "ACTION_LOG_hand_id_fkey" FOREIGN KEY ("hand_id") REFERENCES "public"."HAND"("hand_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."ACTION_LOG" ADD CONSTRAINT "ACTION_LOG_hand_player_id_fkey" FOREIGN KEY ("hand_player_id") REFERENCES "public"."HAND_PLAYER"("hand_player_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."POT" ADD CONSTRAINT "POT_hand_id_fkey" FOREIGN KEY ("hand_id") REFERENCES "public"."HAND"("hand_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."POT_AWARD" ADD CONSTRAINT "POT_AWARD_pot_id_fkey" FOREIGN KEY ("pot_id") REFERENCES "public"."POT"("pot_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."POT_AWARD" ADD CONSTRAINT "POT_AWARD_player_id_fkey" FOREIGN KEY ("player_id") REFERENCES "public"."PLAYER"("player_id") ON DELETE RESTRICT ON UPDATE CASCADE;
