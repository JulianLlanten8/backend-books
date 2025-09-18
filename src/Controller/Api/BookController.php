<?php

namespace App\Controller\Api;

use App\Entity\Book;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\Routing\Attribute\Route;
use App\Repository\BookRepository;
use Symfony\Component\HttpFoundation\Response;

final class BookController extends AbstractController
{
    #[Route('/api/books', name: 'api_books_test', methods: ['GET'])]
    public function index(BookRepository $bookRepository): JsonResponse
    {
        try {

            $books = $bookRepository->findBooksWithAverageRating();
            return $this->json([
                'data' => $books,
                'statusCode' => Response::HTTP_OK,
                'message' => Response::HTTP_OK === 200 ? 'Success' : 'No Content',
                'error' => '',
            ]);
        } catch (\Exception $e) {
            return $this->json([
                'data' => [],
                'statusCode' => Response::HTTP_INTERNAL_SERVER_ERROR,
                'message' => 'An error occurred',
                'error' => $e->getMessage(),
            ]);
        }
    }
}
