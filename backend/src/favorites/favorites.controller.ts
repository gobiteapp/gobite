import { Controller, Get, Post, Delete, Param, UseGuards, Request } from '@nestjs/common';
import { FavoritesService } from './favorites.service';
import { AuthGuard } from '../auth/auth.guard';

@Controller('favorites')
@UseGuards(AuthGuard)
export class FavoritesController {
  constructor(private readonly favoritesService: FavoritesService) {}

  @Get()
  findAll(@Request() req: any) {
    return this.favoritesService.findAll(req.user.id);
  }

  @Post(':restaurantId')
  add(@Request() req: any, @Param('restaurantId') restaurantId: string) {
    return this.favoritesService.add(req.user.id, restaurantId);
  }

  @Delete(':restaurantId')
  remove(@Request() req: any, @Param('restaurantId') restaurantId: string) {
    return this.favoritesService.remove(req.user.id, restaurantId);
  }
}