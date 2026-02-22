import * as dotenv from 'dotenv';
dotenv.config();

import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

const restaurants = [
  {
    name: 'Eslava',
    address: 'Calle Eslava 3, Sevilla',
    latitude: 37.38756,
    longitude: -5.99982,
  },
  {
    name: 'La Brunilda',
    address: 'Calle Galera 5, Sevilla',
    latitude: 37.38690,
    longitude: -5.99300,
  },
  {
    name: 'La Azotea',
    address: 'Calle Jesús del Gran Poder 31, Sevilla',
    latitude: 37.39140,
    longitude: -5.99650,
  },
  {
    name: 'Bar El Comercio',
    address: 'Calle Lineros 9, Sevilla',
    latitude: 37.38630,
    longitude: -5.99250,
  },
  {
    name: 'Duo Tapas',
    address: 'Calle Betis 51, Sevilla',
    latitude: 37.38210,
    longitude: -5.99620,
  },
  {
    name: 'Bar Gonzalo',
    address: 'Calle Mateos Gago 22, Sevilla',
    latitude: 37.38580,
    longitude: -5.99120,
  },
  {
    name: 'Contenedor',
    address: 'Calle San Luis 50, Sevilla',
    latitude: 37.39380,
    longitude: -5.99410,
  },
  {
    name: 'El Rinconcillo',
    address: 'Calle Gerona 40, Sevilla',
    latitude: 37.39220,
    longitude: -5.99560,
  },
  {
    name: 'Bodeguita Casablanca',
    address: 'Calle Adolfo Rodríguez Jurado 12, Sevilla',
    latitude: 37.38870,
    longitude: -5.99430,
  },
  {
    name: 'Bar Alfalfa',
    address: 'Plaza Alfalfa 1, Sevilla',
    latitude: 37.38720,
    longitude: -5.99170,
  },
];

async function main() {
  console.log('Seeding restaurants...');

  for (const data of restaurants) {
    const restaurant = await prisma.restaurant.upsert({
      where: { googlePlaceId: `seed-${data.name.toLowerCase().replace(/\s+/g, '-')}` },
      update: {},
      create: {
        ...data,
        googlePlaceId: `seed-${data.name.toLowerCase().replace(/\s+/g, '-')}`,
      },
    });
    console.log(`  ✓ ${restaurant.name}`);
  }

  console.log(`\nDone. ${restaurants.length} restaurants seeded.`);
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
