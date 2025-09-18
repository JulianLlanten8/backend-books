<?php

namespace App\DataFixtures;

use App\Entity\Book;
use App\Entity\Review;
use Doctrine\Bundle\FixturesBundle\Fixture;
use Doctrine\Persistence\ObjectManager;

class AppFixtures extends Fixture
{
    public function load(ObjectManager $manager): void
    {
        $booksData = [
            ['El Arte de Programar', 'Donald Knuth', 1968],
            ['Clean Code', 'Robert C. Martin', 2008],
            ['Refactoring', 'Martin Fowler', 1999],
        ];

        $books = [];

        foreach ($booksData as [$title, $author, $year]) {
            $book = new Book();
            $book->setTitle($title);
            $book->setAuthor($author);
            $book->setPublishedYear($year);
            $manager->persist($book);
            $books[] = $book;
        }

        // Crear reseñas (mínimo 6, repartidas entre libros)
        $reviewsData = [
            [5, 'Excelente libro', $books[0]],
            [4, 'Muy completo', $books[0]],
            [5, 'Obra maestra', $books[1]],
            [3, 'Algo denso', $books[1]],
            [4, 'Muy útil para mejorar código', $books[2]],
            [2, 'Esperaba más ejemplos', $books[2]],
        ];

        foreach ($reviewsData as [$rating, $comment, $book]) {
            $review = new Review();
            $review->setRating($rating);
            $review->setComment($comment);
            $review->setBook($book);
            $review->setCreatedAt(new \DateTimeImmutable());
            $manager->persist($review);
        }

        $manager->flush();
    }
}
