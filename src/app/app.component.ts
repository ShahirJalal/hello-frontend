import { Component } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { CommonModule } from '@angular/common';
import { HttpClientModule } from '@angular/common/http';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [CommonModule, HttpClientModule],
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent {
  title = 'frontend';
  message = '';
  loading = false;

  constructor(private http: HttpClient) { }

  sayHello() {
    this.loading = true;
    this.http.get('http://localhost:8080/api/hello', { responseType: 'text' })
      .subscribe({
        next: (response) => {
          this.message = response;
          this.loading = false;
        },
        error: (error) => {
          this.message = 'Error connecting to server!';
          this.loading = false;
          console.error('Error fetching data:', error);
        }
      });
  }
}