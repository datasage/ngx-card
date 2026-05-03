import { NgModule } from '@angular/core';
import { NgxCard } from './card.directive';
import {
  NgxCardCvcTemplate,
  NgxCardExpiryTemplate,
  NgxCardNameTemplate,
  NgxCardNumberTemplate,
} from './field-templates.directive';

const DIRECTIVES = [
  NgxCard,
  NgxCardNumberTemplate,
  NgxCardNameTemplate,
  NgxCardExpiryTemplate,
  NgxCardCvcTemplate,
];

@NgModule({
  declarations: [...DIRECTIVES],
  exports: [...DIRECTIVES],
})
export class CardModule {}
