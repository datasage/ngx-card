import {
  AfterViewInit,
  ContentChildren,
  Directive,
  ElementRef,
  Input,
  OnDestroy,
  QueryList,
} from '@angular/core';
import Card from 'card';
import {
  NgxCardCvcTemplate,
  NgxCardExpiryTemplate,
  NgxCardFieldTemplate,
  NgxCardNameTemplate,
  NgxCardNumberTemplate,
} from './field-templates.directive';

export interface NgxCardMessages {
  validDate: string;
  monthYear: string;
}

export interface NgxCardPlaceholders {
  number: string;
  name: string;
  expiry: string;
  cvc: string;
}

const DEFAULT_PLACEHOLDERS: NgxCardPlaceholders = {
  number: '•••• •••• •••• ••••',
  name: 'Full Name',
  expiry: '••/••',
  cvc: '•••',
};

const DEFAULT_MESSAGES: NgxCardMessages = {
  validDate: 'valid\nthru',
  monthYear: 'month/year',
};

@Directive({ selector: '[ngxCard],[card]' })
export class NgxCard implements AfterViewInit, OnDestroy {
  @Input() container?: string | HTMLElement;
  @Input('card-width') width?: number;
  @Input() masks?: Record<string, unknown>;
  @Input() formatting = true;
  @Input() debug = false;

  @Input()
  set messages(value: Partial<NgxCardMessages> | undefined) {
    this._messages = { ...DEFAULT_MESSAGES, ...(value ?? {}) };
  }
  get messages(): NgxCardMessages {
    return this._messages;
  }
  private _messages: NgxCardMessages = { ...DEFAULT_MESSAGES };

  @Input()
  set placeholders(value: Partial<NgxCardPlaceholders> | undefined) {
    this._placeholders = { ...DEFAULT_PLACEHOLDERS, ...(value ?? {}) };
  }
  get placeholders(): NgxCardPlaceholders {
    return this._placeholders;
  }
  private _placeholders: NgxCardPlaceholders = { ...DEFAULT_PLACEHOLDERS };

  @ContentChildren(NgxCardNumberTemplate, { descendants: true })
  numbers!: QueryList<NgxCardNumberTemplate>;

  @ContentChildren(NgxCardNameTemplate, { descendants: true })
  names!: QueryList<NgxCardNameTemplate>;

  @ContentChildren(NgxCardExpiryTemplate, { descendants: true })
  expiries!: QueryList<NgxCardExpiryTemplate>;

  @ContentChildren(NgxCardCvcTemplate, { descendants: true })
  cvcs!: QueryList<NgxCardCvcTemplate>;

  private card?: Card;

  constructor(private element: ElementRef<HTMLElement>) {}

  ngAfterViewInit(): void {
    this.card = new Card({
      form: this.element.nativeElement,
      container: this.container,
      width: this.width,
      formSelectors: {
        numberInput: this.selectorsFor(this.numbers),
        expiryInput: this.selectorsFor(this.expiries),
        cvcInput: this.selectorsFor(this.cvcs),
        nameInput: this.selectorsFor(this.names),
      },
      formatting: this.formatting,
      messages: this.messages,
      placeholders: this.placeholders,
      masks: this.masks,
      debug: this.debug,
    });
  }

  ngOnDestroy(): void {
    this.card?.destroy?.();
    this.card = undefined;
  }

  private selectorsFor(list: QueryList<NgxCardFieldTemplate>): string {
    return list
      .map(
        (tpl) =>
          `${tpl.elementRef.nativeElement.tagName.toLowerCase()}[name="${tpl.name}"]`,
      )
      .join(', ');
  }
}
