using System.Threading.Tasks;

namespace OrderItemsReserver
{
    public interface IAlternateOrderProcessor
    {
        Task<bool> ProcessAsync(string queueItem);
    }
}
