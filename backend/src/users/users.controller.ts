import { Controller, Get, Put, Body, UseGuards, Request } from '@nestjs/common';
import { UsersService } from './users.service';
import { AuthGuard } from '../auth/auth.guard';

@Controller('users')
@UseGuards(AuthGuard)
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get('me')
  getProfile(@Request() req: any) {
    return this.usersService.findOne(req.user.id);
  }

  @Put('me')
  updateProfile(@Request() req: any, @Body() body: {
    name?: string;
    avatarUrl?: string;
  }) {
    return this.usersService.update(req.user.id, body);
  }
}