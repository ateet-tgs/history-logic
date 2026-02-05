import { Module, Global } from '@nestjs/common';
import { Sequelize } from 'sequelize';
import { ENV } from '../common/constants';

export const SEQUELIZE = 'SEQUELIZE';

@Global()
@Module({
  providers: [
    {
      provide: SEQUELIZE,
      useFactory: (): Sequelize => {
        return new Sequelize({
          dialect: 'mysql',
          host: ENV.DB_HOST,
          port: 3306,
          username: ENV.DB_USER,
          password: ENV.DB_PASS,
          database: ENV.DB_NAME,
          logging: false,
          define: {
            timestamps: false,
          },
        });
      },
    },
  ],
  exports: [SEQUELIZE],
})
export class SequelizeModule {}
