import * as dotenv from 'dotenv';
dotenv.config();

import { PrismaClient, VideoSource, VideoStatus } from '@prisma/client';

const prisma = new PrismaClient();

const videos: { restaurantName: string; tiktokUrl: string }[] = [
  {
    restaurantName: 'Bodeguita Casablanca',
    tiktokUrl: 'https://www.tiktok.com/@miguedesevilla/video/6966863283659738374',
  },
  {
    restaurantName: 'Bodeguita Casablanca',
    tiktokUrl: 'https://www.tiktok.com/@chef_aprueba/video/7150231236278062341',
  },
  {
    restaurantName: 'Eslava',
    tiktokUrl: 'https://www.tiktok.com/@loquedigaelchef/video/7420141262138821921',
  },
  {
    restaurantName: 'Eslava',
    tiktokUrl: 'https://www.tiktok.com/@jnotions/video/7536931323009682710',
  },
  {
    restaurantName: 'La Brunilda',
    tiktokUrl: 'https://www.tiktok.com/@alertafoodie/video/7246833959278005531',
  },
  {
    restaurantName: 'La Brunilda',
    tiktokUrl: 'https://www.tiktok.com/@eldasworld/video/7467251240552975621',
  },
  {
    restaurantName: 'La Azotea',
    tiktokUrl: 'https://www.tiktok.com/@foodcanastera/video/7147014068199574789',
  },
  {
    restaurantName: 'La Azotea',
    tiktokUrl: 'https://www.tiktok.com/@foodsevillamalagaandmore/video/7160365360422669574',
  },
];

function extractHandle(tiktokUrl: string): string {
  const match = tiktokUrl.match(/tiktok\.com\/@([^/]+)/);
  return match ? `@${match[1]}` : '';
}

async function main() {
  console.log('Seeding videos...');

  for (const { restaurantName, tiktokUrl } of videos) {
    const restaurant = await prisma.restaurant.findFirst({
      where: { name: restaurantName },
    });

    if (!restaurant) {
      console.warn(`  ⚠ Restaurant not found: ${restaurantName}`);
      continue;
    }

    const existing = await prisma.video.findFirst({
      where: { tiktokUrl },
    });

    if (existing) {
      console.log(`  – Already exists: ${tiktokUrl}`);
      continue;
    }

    await prisma.video.create({
      data: {
        restaurantId: restaurant.id,
        source: VideoSource.TIKTOK,
        tiktokUrl,
        creatorHandle: extractHandle(tiktokUrl),
        status: VideoStatus.APPROVED,
      },
    });

    console.log(`  ✓ ${restaurantName} — ${extractHandle(tiktokUrl)}`);
  }

  console.log(`\nDone. ${videos.length} videos processed.`);
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
