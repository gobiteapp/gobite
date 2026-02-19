import { Module } from '@nestjs/common';
import { PrismaModule } from './prisma/prisma.module';
import { AuthModule } from './auth/auth.module';
import { RestaurantsModule } from './restaurants/restaurants.module';
import { FavoritesModule } from './favorites/favorites.module';
import { VideosModule } from './videos/videos.module';

@Module({
  imports: [PrismaModule, AuthModule, RestaurantsModule, FavoritesModule, VideosModule],
})
export class AppModule {}