-- CreateTable
CREATE TABLE "public"."Player" (
    "player_id" SERIAL NOT NULL,
    "player_name" VARCHAR(255) NOT NULL,

    CONSTRAINT "Player_pkey" PRIMARY KEY ("player_id")
);
