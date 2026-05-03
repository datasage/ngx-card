import { Attribute, Directive, ElementRef, HostBinding, OnInit } from '@angular/core';
import { uniqueId } from './util';

@Directive()
export abstract class NgxCardFieldTemplate implements OnInit {
  @HostBinding('name') name: string;

  protected abstract readonly prefix: string;

  constructor(
    public elementRef: ElementRef<HTMLElement>,
    @Attribute('name') name: string | null,
  ) {
    this.name = name ?? '';
  }

  ngOnInit(): void {
    if (!this.name) {
      this.name = uniqueId(this.prefix);
    }
  }
}

@Directive({ selector: '[ngxCardNumber],[card-number]' })
export class NgxCardNumberTemplate extends NgxCardFieldTemplate {
  protected readonly prefix = 'number';
}

@Directive({ selector: '[ngxCardName],[card-name]' })
export class NgxCardNameTemplate extends NgxCardFieldTemplate {
  protected readonly prefix = 'name';
}

@Directive({ selector: '[ngxCardExpiry],[card-expiry]' })
export class NgxCardExpiryTemplate extends NgxCardFieldTemplate {
  protected readonly prefix = 'expiry';
}

@Directive({ selector: '[ngxCardCvc],[card-cvc]' })
export class NgxCardCvcTemplate extends NgxCardFieldTemplate {
  protected readonly prefix = 'cvc';
}
